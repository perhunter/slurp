#!/usr/local/bin/perl

use strict ;
use warnings ;

use Getopt::Long ;
use Benchmark qw( timethese cmpthese ) ;
use Carp ;
use FileHandle ;
use Fcntl qw( :DEFAULT :seek );

use File::Slurp () ;

my $file = 'slurp_data' ;

GetOptions (\my %opts,
	qw( slurp spew scalar list sizes=s key duration=i help ) ) ;

parse_options() ;

run_benchmarks() ;

unlink $file ;

exit ;

my( @lines, $text, $size ) ;

sub run_benchmarks {

	foreach my $size ( @{$opts{sizes}} ) {

		@lines = ( 'a' x 80 . "\n") x $size ;
		$text = join( '', @lines ) ;
		$size = length $text ;

		File::Slurp::write_file( $file, $text ) ;

# 		bench_list_slurp( $size ) if $opts{list} && $opts{slurp} ;
# 		bench_scalar_slurp( $size ) if $opts{scalar} && $opts{slurp} ;
 		bench_spew_list()
# 		bench_scalar_spew( $size ) if $opts{scalar} && $opts{spew} ;
	}
}

sub bench_spew_list {

	return unless $opts{list} && $opts{spew} ;

	print "\n\nWriting (Spew) a list of lines: Size = $size bytes\n\n" ;

	my $result = timethese( $opts{duration}, {

 		'FS::write_file' =>
 	    		sub { File::Slurp::write_file( $file, @lines ) },

		'print' =>
	    		sub { print_file( $file, @lines ) },

		'print/join' =>
			sub { print_join_file( $file, @lines ) },

		'syswrite/join' =>
			sub { syswrite_join_file( $file, @lines ) },

		'original write_file' =>
			sub { orig_write_file( $file, @lines ) },

	} ) ;

	cmpthese( $result ) ;
}

# sub bench_scalar_spew {

# 	my ( $size ) = @_ ;

# 	print "\n\nScalar Spew of $size file\n\n" ;

# 	my $result = timethese( $dur, {

#  		new =>
#  	    		sub { File::Slurp::write_file( $file, $text ) },

#  		new_ref =>
#  	    		sub { File::Slurp::write_file( $file, \$text ) },

# 		print_file =>
# 	    		sub { print_file( $file, $text ) },

# 		print_join_file =>
# 	    		sub { print_join_file( $file, $text ) },

# 		syswrite_file =>
# 	    		sub { syswrite_file( $file, $text ) },

# 		syswrite_file2 =>
# 	    		sub { syswrite_file2( $file, $text ) },

# 		orig_write_file =>
# 			sub { orig_write_file( $file, $text ) },

# 	} ) ;

# 	cmpthese( $result ) ;
# }

# sub bench_scalar_slurp {

# 	my ( $size ) = @_ ;

# 	print "\n\nScalar Slurp of $size file\n\n" ;

# 	my $buffer ;

# 	my $result = timethese( $dur, {

# 		new =>
# 	    		sub { my $text = File::Slurp::read_file( $file ) },

# 		new_buf_ref =>
# 	    		sub { my $text ;
# 			   File::Slurp::read_file( $file, buf_ref => \$text ) },
# 		new_buf_ref2 =>
# 	    		sub { 
# 			   File::Slurp::read_file( $file, buf_ref => \$buffer ) },
# 		new_scalar_ref =>
# 	    		sub { my $text =
# 			    File::Slurp::read_file( $file, scalar_ref => 1 ) },

# 		read_file =>
# 	    		sub { my $text = read_file( $file ) },

# 		sysread_file =>
# 	    		sub { my $text = sysread_file( $file ) },

# 		orig_read_file =>
# 			sub { my $text = orig_read_file( $file ) },

# 		'Slurp.pm scalar' =>
# 			sub { my $text = slurp_scalar( $file ) },

# 		file_contents =>
# 			sub { my $text = file_contents( $file ) },

# 		file_contents_no_OO =>
# 			sub { my $text = file_contents_no_OO( $file ) },
# 	} ) ;

# 	cmpthese( $result ) ;
# }

# sub bench_list_slurp {

# 	my ( $size ) = @_ ;

# 	print "\n\nList Slurp of $size file\n\n" ;

# 	my $result = timethese( $dur, {

# 		new =>
# 	    		sub { my @lines = File::Slurp::read_file( $file ) },

# 		new_array_ref =>
# 	    		sub { my $lines_ref =
# 			     File::Slurp::read_file( $file, array_ref => 1 ) },

# 		new_in_anon_array =>
# 	    		sub { my $lines_ref =
# 			     [ File::Slurp::read_file( $file ) ] },

# 		read_file =>
# 	    		sub { my @lines = read_file( $file ) },

# 		sysread_file =>
# 	    		sub { my @lines = sysread_file( $file ) },

# 		orig_read_file =>
# 			sub { my @lines = orig_read_file( $file ) },

# 		'Slurp.pm to array' =>
# 			sub { my @lines = slurp_array( $file ) },

# 		orig_slurp_to_array_ref =>
# 			sub { my $lines_ref = orig_slurp_to_array( $file ) },
# 	} ) ;

# 	cmpthese( $result ) ;
# }


###########################
# write file benchmark subs
###########################


sub print_file {

	my( $file_name ) = shift ;

	local( *FH ) ;

	open( FH, ">$file_name" ) || carp "can't create $file_name $!" ;

	print FH @_ ;
}

sub print_file2 {

	my( $file_name ) = shift ;

	local( *FH ) ;

	my $mode = ( -e $file_name ) ? '<' : '>' ;

	open( FH, "+$mode$file_name" ) || carp "can't create $file_name $!" ;

	print FH @_ ;
}

sub print_join_file {

	my( $file_name ) = shift ;

	local( *FH ) ;

	my $mode = ( -e $file_name ) ? '<' : '>' ;

	open( FH, "+$mode$file_name" ) || carp "can't create $file_name $!" ;

	print FH join( '', @_ ) ;
}


sub syswrite_join_file {

	my( $file_name ) = shift ;

	local( *FH ) ;

	open( FH, ">$file_name" ) || carp "can't create $file_name $!" ;

	syswrite( FH, join( '', @_ ) ) ;
}

sub sysopen_syswrite_join_file {

	my( $file_name ) = shift ;

	local( *FH ) ;

	sysopen( FH, $file_name, O_WRONLY | O_CREAT ) ||
				carp "can't create $file_name $!" ;

	syswrite( FH, join( '', @_ ) ) ;
}

sub orig_write_file
{
	my ($f, @data) = @_;

	local(*F);

	open(F, ">$f") || croak "open >$f: $!";
	(print F @data) || croak "write $f: $!";
	close(F) || croak "close $f: $!";
	return 1;
}


#######################
# top level subs for script

#######################

sub parse_options {

	help() if $opts{help} ;

	key() if $opts{key} ;

	unless( $opts{spew} || $opts{slurp} ) {

		$opts{spew} = 1 ;
		$opts{slurp} = 1 ;
	}

	unless( $opts{list} || $opts{scalar} ) {

		$opts{list} = 1 ;
		$opts{scalar} = 1 ;
	}

	$opts{sizes} = [split ',', ( $opts{sizes} || '10,100,1000' ) ];

	$opts{duration} ||= -2 ;
}

sub key {

	print <<'KEY' ;

Key to Slurp/Spew Benchmarks


Write a list of lines to a file

	Key			Description/Source
	---			------------------

	FS:write_file		Current File::Slurp::write_file
	FS:write_file_ref	Current File::Slurp::write_file (scalar ref)
	print			Open a file and call print()
	syswrite/join		Open a file, call syswrite on joined lines
	sysopen/syswrite	Sysopen a file, call syswrite on joined lines
	original write_file	Original (pre 9999.*) File::Slurp::write_file


KEY

	exit ;
}

sub help {

	die <<DIE ;

Usage: $0 [--list] [--scalar] [--slurp] [--spew]
          [--sizes=10,100] [--help]

	--list		Run the list context benchmarks
	--scalar	Run the scalar context benchmarks
			Those default to on unless one is set

	--slurp		Run the slurp benchmarks
	--spew		Run the spew benchmarks
			Those default to on unless one is set

	--sizes		Comma separated list of file sizes to benchmark
			Defaults to 10,100,1000

	--key		Print the benchmark names and code orig_ins

	--help		Print this help text

DIE

}


__END__


sub bench_scalar_spew {

	my ( $size ) = @_ ;

	print "\n\nScalar Spew of $size file\n\n" ;

	my $result = timethese( $dur, {

 		new =>
 	    		sub { File::Slurp::write_file( $file, $text ) },

 		new_ref =>
 	    		sub { File::Slurp::write_file( $file, \$text ) },

		print_file =>
	    		sub { print_file( $file, $text ) },

		print_join_file =>
	    		sub { print_join_file( $file, $text ) },

		syswrite_file =>
	    		sub { syswrite_file( $file, $text ) },

		syswrite_file2 =>
	    		sub { syswrite_file2( $file, $text ) },

		orig_write_file =>
			sub { orig_write_file( $file, $text ) },

	} ) ;

	cmpthese( $result ) ;
}

sub bench_scalar_slurp {

	my ( $size ) = @_ ;

	print "\n\nScalar Slurp of $size file\n\n" ;

	my $buffer ;

	my $result = timethese( $dur, {

		new =>
	    		sub { my $text = File::Slurp::read_file( $file ) },

		new_buf_ref =>
	    		sub { my $text ;
			   File::Slurp::read_file( $file, buf_ref => \$text ) },
		new_buf_ref2 =>
	    		sub { 
			   File::Slurp::read_file( $file, buf_ref => \$buffer ) },
		new_scalar_ref =>
	    		sub { my $text =
			    File::Slurp::read_file( $file, scalar_ref => 1 ) },

		read_file =>
	    		sub { my $text = read_file( $file ) },

		sysread_file =>
	    		sub { my $text = sysread_file( $file ) },

		orig_read_file =>
			sub { my $text = orig_read_file( $file ) },

		orig_slurp =>
			sub { my $text = orig_slurp_to_scalar( $file ) },

		file_contents =>
			sub { my $text = file_contents( $file ) },

		file_contents_no_OO =>
			sub { my $text = file_contents_no_OO( $file ) },
	} ) ;

	cmpthese( $result ) ;
}

sub bench_list_slurp {

	my ( $size ) = @_ ;

	print "\n\nList Slurp of $size file\n\n" ;

	my $result = timethese( $dur, {

		new =>
	    		sub { my @lines = File::Slurp::read_file( $file ) },

		new_array_ref =>
	    		sub { my $lines_ref =
			     File::Slurp::read_file( $file, array_ref => 1 ) },

		new_in_anon_array =>
	    		sub { my $lines_ref =
			     [ File::Slurp::read_file( $file ) ] },

		read_file =>
	    		sub { my @lines = read_file( $file ) },

		sysread_file =>
	    		sub { my @lines = sysread_file( $file ) },

		orig_read_file =>
			sub { my @lines = orig_read_file( $file ) },

		orig_slurp_to_array =>
			sub { my @lines = orig_slurp_to_array( $file ) },

		orig_slurp_to_array_ref =>
			sub { my $lines_ref = orig_slurp_to_array( $file ) },
	} ) ;

	cmpthese( $result ) ;
}

######################################
# uri's old fast slurp

sub read_file {

	my( $file_name ) = shift ;

	local( *FH ) ;
	open( FH, $file_name ) || carp "can't open $file_name $!" ;

	return <FH> if wantarray ;

	my $buf ;

	read( FH, $buf, -s FH ) ;
	return $buf ;
}

sub sysread_file {

	my( $file_name ) = shift ;

	local( *FH ) ;
	open( FH, $file_name ) || carp "can't open $file_name $!" ;

	return <FH> if wantarray ;

	my $buf ;

	sysread( FH, $buf, -s FH ) ;
	return $buf ;
}

######################################
# from File::Slurp.pm on cpan

sub orig_read_file
{
	my ($file) = @_;

	local($/) = wantarray ? $/ : undef;
	local(*F);
	my $r;
	my (@r);

	open(F, "<$file") || croak "open $file: $!";
	@r = <F>;
	close(F) || croak "close $file: $!";

	return $r[0] unless wantarray;
	return @r;
}


######################################
# from Slurp.pm on cpan

sub slurp { 
    local( $/, @ARGV ) = ( wantarray ? $/ : undef, @_ ); 
    return <ARGV>;
}

sub slurp_array {
    my @array = slurp( @_ );
    return wantarray ? @array : \@array;
}

sub slurp_scalar {
    my $scalar = slurp( @_ );
    return $scalar;
}

######################################
# very slow slurp code used by a client

sub file_contents {
    my $file = shift;
    my $fh = new FileHandle $file or
        warn("Util::file_contents:Can't open file $file"), return '';
    return join '', <$fh>;
}

# same code but doesn't use FileHandle.pm

sub file_contents_no_OO {
    my $file = shift;

	local( *FH ) ;
	open( FH, $file ) || carp "can't open $file $!" ;

    return join '', <FH>;
}

##########################
