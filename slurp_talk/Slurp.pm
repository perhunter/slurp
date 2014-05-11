package File::Slurp;

use strict;

use Carp ;
use Fcntl qw( :DEFAULT :seek ) ;
use Symbol ;

use base 'Exporter' ;
use vars qw( %EXPORT_TAGS @EXPORT_OK $VERSION  @EXPORT) ;

%EXPORT_TAGS = ( 'all' => [
	qw( read_file write_file overwrite_file append_file read_dir ) ] ) ;

#@EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );
@EXPORT = ( @{ $EXPORT_TAGS{'all'} } );

$VERSION = '9999.01';


sub read_file {

	my( $file_name, %args ) = @_ ;

	my $buf ;
	my $buf_ref = $args{'buf_ref'} || \$buf ;

	${$buf_ref} = '' ;

	my( $read_fh, $size_left, $blk_size ) ;

	if ( defined( fileno( $file_name ) ) ) {

		$read_fh = $file_name ;
		$blk_size = $args{'blk_size'} || 1024 * 1024 ;
		$size_left = $blk_size ;
	}
	else {

		my $mode = O_RDONLY ;
		$mode |= O_BINARY if $args{'binmode'} ;


		$read_fh = gensym ;
		unless ( sysopen( $read_fh, $file_name, $mode ) ) {
			@_ = ( \%args, "read_file '$file_name' - sysopen: $!");
			goto &error ;
		}

		$size_left = -s $read_fh ;
	}

	while( 1 ) {

		my $read_cnt = sysread( $read_fh, ${$buf_ref},
				$size_left, length ${$buf_ref} ) ;

		if ( defined $read_cnt ) {

			last if $read_cnt == 0 ;
			next if $blk_size ;

			$size_left -= $read_cnt ;
			last if $size_left <= 0 ;
			next ;
		}

# handle the read error

		@_ = ( \%args, "read_file '$file_name' - sysread: $!");
		goto &error ;
	}

# handle array ref

	return [ split( m|(?<=$/)|, ${$buf_ref} ) ] if $args{'array_ref'}  ;

# handle list context

	return split( m|(?<=$/)|, ${$buf_ref} ) if wantarray ;

# handle scalar ref

	return $buf_ref if $args{'scalar_ref'} ;

# handle scalar context

	return ${$buf_ref} if defined wantarray ;

# handle void context (return scalar by buffer reference)

	return ;
}

sub write_file {

	my $file_name = shift ;

	my $args = ( ref $_[0] eq 'HASH' ) ? shift : {} ;

	my( $buf_ref, $write_fh, $no_truncate ) ;

# get the buffer ref - either passed by name or first data arg or autovivified
# ${$buf_ref} will have the data after this

	if ( ref $args->{'buf_ref'} eq 'SCALAR' ) {

		$buf_ref = $args->{'buf_ref'} ;
	}
	elsif ( ref $_[0] eq 'SCALAR' ) {

		$buf_ref = shift ;
	}
	elsif ( ref $_[0] eq 'ARRAY' ) {

		${$buf_ref} = join '', @{$_[0]} ;
	}
	else {

		${$buf_ref} = join '', @_ ;
	}

	if ( defined( fileno( $file_name ) ) ) {

		$write_fh = $file_name ;
		$no_truncate = 1 ;
	}
	else {

		my $mode = O_WRONLY | O_CREAT ;
		$mode |= O_BINARY if $args->{'binmode'} ;
		$mode |= O_APPEND if $args->{'append'} ;

		$write_fh = gensym ;
		unless ( sysopen( $write_fh, $file_name, $mode ) ) {
			@_ = ( $args, "write_file '$file_name' - sysopen: $!");
			goto &error ;
		}

	}

	my $size_left = length( ${$buf_ref} ) ;
	my $offset = 0 ;

	do {
		my $write_cnt = syswrite( $write_fh, ${$buf_ref},
				$size_left, $offset ) ;

		unless ( defined $write_cnt ) {

			@_ = ( $args, "write_file '$file_name' - syswrite: $!");
			goto &error ;
		}

		$size_left -= $write_cnt ;
		$offset += $write_cnt ;

	} while( $size_left > 0 ) ;

	truncate( $write_fh,
		  sysseek( $write_fh, 0, SEEK_CUR ) ) unless $no_truncate ;

	close( $write_fh ) ;

	return 1 ;
}

# this is for backwards compatibility with the previous File::Slurp module. 
# write_file always overwrites an existing file

*overwrite_file = \&write_file ;

# the current write_file has an append mode so we use that. this
# supports the same API with an optional second argument which is a
# hash ref of options.

sub append_file {

	my $args = $_[1] ;
	if ( ref $args eq 'HASH' ) {
		$args->{append} = 1 ;
	}
	else {

		splice( @_, 1, 0, { append => 1 } ) ;
	}
	
	goto &write_file
}

sub read_dir {
	my ($dir, %args ) = @_;

	local(*DIRH);

	if ( opendir( DIRH, $dir ) ) {
		return grep( $_ ne "." && $_ ne "..", readdir(DIRH));
	}

	@_ = ( \%args, "read_dir '$dir' - opendir: $!" ) ; goto &error ;

	return undef ;
}

my %err_func = (
	carp => \&carp,
	croak => \&croak,
) ;

sub error {

	my( $args, $err_msg ) = @_ ;

#print $err_msg ;

 	my $func = $err_func{ $args->{'err_mode'} || 'croak' } ;

	return unless $func ;

	$func->($err_msg) ;

	return undef ;
}

1;
__END__

=head1 NAME

File::Slurp - Efficient Reading/Writing of Complete Files

=head1 SYNOPSIS

  use File::Slurp;

  my $text = read_file( 'filename' ) ;
  my @lines = read_file( 'filename' ) ;

  write_file( 'filename', @lines ) ;

=head1 DESCRIPTION

This module provides subs that allow you to read or write entire files
with one simple call. They are designed to be simple to use, have
flexible ways to pass in or get the file contents and to be very
efficient.  There is also a sub to read in all the files in a
directory other than C<.> and C<..>

Note that these slurp/spew subs work only for files and not for pipes
or stdio. If you want to slurp the latter, use the standard techniques
such as setting $/ to undef, reading <> in a list context, or printing
all you want to STDOUT.

=head2 B<read_file>

This sub reads in an entire file and returns its contents to the
caller. In list context it will return a list of lines (using the
current value of $/ as the separator. In scalar context it returns the
entire file as a single scalar.

  my $text = read_file( 'filename' ) ;
  my @lines = read_file( 'filename' ) ;

The first argument to C<read_file> is the filename and the rest of the
arguments are key/value pairs which are optional and which modify the
behavior of the call. Other than binmode the options all control how
the slurped file is returned to the caller.

If the first argument is a file handle reference or I/O object (if
fileno returns a defined value), then that handle is slurped in. This
mode is supported so you slurp handles such as <DATA>, \*STDIN. See
the test handle.t for an example that does C<open( '-|' )> and child
process spews data to the parant which slurps it in.  All of the
options that control how the data is returned to the caller still work
in this case.

The options are:

=head3 binmode

If you set the binmode option, then the file will be slurped in binary
mode.

	my $bin_data = read_file( $bin_file, binmode => ':raw' ) ;

NOTE: this actually sets the O_BINARY mode flag for sysopen. It
probably should call binmode and pass its argument to support other
file modes.

=head3 array_ref

If this boolean option is set, the return value (only in scalar
context) will be an array reference which contains the lines of the
slurped file. The following two calls are equivilent:

	my $lines_ref = read_file( $bin_file, array_ref => 1 ) ;
	my $lines_ref = [ read_file( $bin_file ) ] ;

=head3 scalar_ref

If this boolean option is set, the return value (only in scalar
context) will be an scalar reference to a string which is the contents
of the slurped file. This will usually be faster than returning the
plain scalar.

	my $text_ref = read_file( $bin_file, scalar_ref => 1 ) ;

=head3 buf_ref

You can use this option to pass in a scalar reference and the slurped
file contents will be stored in the scalar. This can be used in
conjunction with any of the other options.

	my $text_ref = read_file( $bin_file, buf_ref => \$buffer,
					     array_ref => 1 ) ;
	my @lines = read_file( $bin_file, buf_ref => \$buffer ) ;

=head3 blk_size

You can use this option to set the block size used when slurping from an already open handle (like \*STDIN). It defaults to 1MB.

	my $text_ref = read_file( $bin_file, blk_size => 10_000_000,
					     array_ref => 1 ) ;

=head3 err_mode

You can use this option to control how read_file behaves when an error
occurs. This option defaults to 'croak'. You can set it to 'carp' or
to 'quiet to have no error handling. This code wants to carp and then
read abother file if it fails.

	my $text_ref = read_file( $file, err_mode => 'carp' ) ;
	unless ( $text_ref ) {

		# read a different file but croak if not found
		$text_ref = read_file( $another_file ) ;
	}
	
	# process ${$text_ref}

=head2 B<write_file>

This sub writes out an entire file in one call.

  write_file( 'filename', @data ) ;

The first argument to C<write_file> is the filename. The next argument
is an optional hash reference and it contains key/values that can
modify the behavior of C<write_file>. The rest of the argument list is
the data to be written to the file.

  write_file( 'filename', {append => 1 }, @data ) ;
  write_file( 'filename', {binmode => ':raw' }, $buffer ) ;

As a shortcut if the first data argument is a scalar or array
reference, it is used as the only data to be written to the file. Any
following arguments in @_ are ignored. This is a faster way to pass in
the output to be written to the file and is equivilent to the
C<buf_ref> option. These following pairs are equivilent but the pass
by reference call will be faster in most cases (especially with larger
files).

  write_file( 'filename', \$buffer ) ;
  write_file( 'filename', $buffer ) ;

  write_file( 'filename', \@lines ) ;
  write_file( 'filename', @lines ) ;

If the first argument is a file handle reference or I/O object (if
fileno returns a defined value), then that handle is slurped in. This
mode is supported so you spew to handles such as \*STDOUT. See the
test handle.t for an example that does C<open( '-|' )> and child
process spews data to the parant which slurps it in.  All of the
options that control how the data is passes into C<write_file> still
work in this case.

The options are:

=head3 binmode

If you set the binmode option, then the file will be written in binary
mode.

	write_file( $bin_file, {binmode => ':raw'}, @data ) ;

NOTE: this actually sets the O_BINARY mode flag for sysopen. It
probably should call binmode and pass its argument to support other
file modes.

=head3 buf_ref

You can use this option to pass in a scalar reference which has the
data to be written. If this is set then any data arguments (including
the scalar reference shortcut) in @_ will be ignored. These are
equivilent:

	write_file( $bin_file, { buf_ref => \$buffer } ) ;
	write_file( $bin_file, \$buffer ) ;
	write_file( $bin_file, $buffer ) ;

=head3 append

If you set this boolean option, the data will be written at the end of
the current file.

	write_file( $file, {append => 1}, @data ) ;

C<write_file> croaks if it cannot open the file. It returns true if it
succeeded in writing out the file and undef if there was an
error. (Yes, I know if it croaks it can't return anything but that is
for when I add the options to select the error handling mode).

=head3 err_mode

You can use this option to control how C<write_file> behaves when an
error occurs. This option defaults to 'croak'. You can set it to
'carp' or to 'quiet to have no error handling. If the first call to
C<write_file> fails it will carp and then write to another file. If the
second call to C<write_file> fails, it will croak.

	unless ( write_file( $file, { err_mode => 'carp', \$data ) ;

		# write a different file but croak if not found
		write_file( $other_file, \$data ) ;
	}

=head2 overwrite_file

This sub is just a typeglob alias to write_file since write_file
always overwrites an existing file. This sub is supported for
backwards compatibility with the original version of this module. See
write_file for its API and behavior.

=head2 append_file

This sub will write its data to the end of the file. It is a wrapper
around write_file and it has the same API so see that for the full
documentation. These calls are equivilent:

	append_file( $file, @data ) ;
	write_file( $file, {append => 1}, @data ) ;

=head2 read_dir

This sub reads all the file names from directory and returns them to
the caller but C<.> and C<..> are removed.

	my @files = read_dir( '/path/to/dir' ) ;

It croaks if it cannot open the directory.

=head2 EXPORT

  read_file write_file overwrite_file append_file read_dir

=head1 AUTHOR

Uri Guttman, E<lt>uri@stemsystems.comE<gt>

=cut
