#!/usr/local/bin/perl

use strict ;
use warnings ;

use Getopt::Long ;
use Benchmark qw( timethese cmpthese ) ;
use Carp ;
use FileHandle ;
use Fcntl qw( :DEFAULT :seek );

use File::Slurp () ;

my $file_name = 'slurp_data' ;
my( @lines, $text ) ;

my %opts ;

parse_options() ;

run_benchmarks() ;

unlink $file_name ;

exit ;

sub run_benchmarks {

	foreach my $size ( @{$opts{size_list}} ) {

		@lines = ( 'a' x 80 . "\n") x ( $size / 81 + 1 ) ;
		$text = join( '', @lines ) ;

		my $overage = length($text) - $size ;
		substr( $text, -$overage, $overage, '' ) ;
		substr( $lines[-1], -$overage, $overage, '' ) ;

		if ( $opts{slurp} ) {

			File::Slurp::write_file( $file_name, $text ) ;

			bench_list_slurp( $size ) if $opts{list} ;
	 		bench_scalar_slurp( $size ) if $opts{scalar} ;
		}

		if ( $opts{spew} ) {

			bench_spew_list( $size ) if $opts{list} ;
	 		bench_scalar_spew( $size ) if $opts{scalar} ;
		}
	}
}

##########################################

sub bench_spew_list {

	my( $size ) = @_ ;

	print "\n\nWriting (Spew) a list of lines: Size = $size bytes\n\n" ;

	my $result = timethese( $opts{iterations}, {
 		'FS::write_file'	=> sub { unlink $file_name if $opts{unlink} ; 
			File::Slurp::write_file( $file_name, @lines ) },
 		'FS::write_file Aref'	=> sub { unlink $file_name if $opts{unlink} ; 
			File::Slurp::write_file( $file_name, \@lines ) },
		'print'			=> sub { unlink $file_name if $opts{unlink} ; 
			print_file( $file_name, @lines ) },
		'print/join'		=> sub { unlink $file_name if $opts{unlink} ; 
			print_join_file( $file_name, @lines ) },
		'syswrite/join'		=> sub { unlink $file_name if $opts{unlink} ;
			syswrite_join_file( $file_name, @lines ) },
		'original write_file'	=> sub {  unlink $file_name if $opts{unlink} ; 
			orig_write_file( $file_name, @lines ) },
	} ) ;

	cmpthese( $result ) ;
}

sub print_file {

	my( $file_name ) = shift ;

	local( *FH ) ;
	open( FH, ">$file_name" ) || carp "can't create $file_name $!" ;

	print FH @_ ;
}

sub print_join_file {

	my( $file_name ) = shift ;

	local( *FH ) ;
	open( FH, ">$file_name" ) || carp "can't create $file_name $!" ;

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

##########################################

sub bench_scalar_spew {

	my ( $size ) = @_ ;

	print "\n\nWriting (Spew) a scalar: Size = $size bytes\n\n" ;

	my $result = timethese( $opts{iterations}, {
		'FS::write_file'	=> sub { unlink $file_name if $opts{unlink} ;
			File::Slurp::write_file( $file_name, $text ) },
		'FS::write_file Sref'	=> sub { unlink $file_name if $opts{unlink} ; 
			File::Slurp::write_file( $file_name, \$text ) },
		'print'			=> sub { unlink $file_name if $opts{unlink} ; 
			print_file( $file_name, $text ) },
		'syswrite_file'		=> sub { unlink $file_name if $opts{unlink} ; 
			syswrite_file( $file_name, $text ) },
		'syswrite_file_ref'	=> sub { unlink $file_name if $opts{unlink} ; 
			syswrite_file_ref( $file_name, \$text ) },
		'orig_write_file'	=> sub { unlink $file_name if $opts{unlink} ; 
			orig_write_file( $file_name, $text ) },
	} ) ;

	cmpthese( $result ) ;
}

sub syswrite_file {

	my( $file_name, $text ) = @_ ;

	local( *FH ) ;
	open( FH, ">$file_name" ) || carp "can't create $file_name $!" ;

	syswrite( FH, $text ) ;
}

sub syswrite_file_ref {

	my( $file_name, $text_ref ) = @_ ;

	local( *FH ) ;
	open( FH, ">$file_name" ) || carp "can't create $file_name $!" ;

	syswrite( FH, ${$text_ref} ) ;
}

#############################################


# sub bench_scalar_slurp {

# 	my ( $size ) = @_ ;

# 	print "\n\nScalar Slurp of $size bytes\n\n" ;

# 	my $buffer ;

# 	my $result = timethese( $dur, {

# 		new =>
# 	    		sub { my $text = File::Slurp::read_file( $file_name ) },

# 		new_buf_ref =>
# 	    		sub { my $text ;
# 			   File::Slurp::read_file( $file_name, buf_ref => \$text ) },
# 		new_buf_ref2 =>
# 	    		sub { 
# 			   File::Slurp::read_file( $file_name, buf_ref => \$buffer ) },
# 		new_scalar_ref =>
# 	    		sub { my $text =
# 			    File::Slurp::read_file( $file_name, scalar_ref => 1 ) },

# 		read_file =>
# 	    		sub { my $text = read_file( $file_name ) },

# 		sysread_file =>
# 	    		sub { my $text = sysread_file( $file_name ) },

# 		orig_read_file =>
# 			sub { my $text = orig_read_file( $file_name ) },

# 		'Slurp.pm scalar' =>
# 			sub { my $text = slurp_scalar( $file_name ) },

# 		file_contents =>
# 			sub { my $text = file_contents( $file_name ) },

# 		file_contents_no_OO =>
# 			sub { my $text = file_contents_no_OO( $file_name ) },
# 	} ) ;

# 	cmpthese( $result ) ;
# }

# sub bench_list_slurp {

# 	my ( $size ) = @_ ;

# 	print "\n\nList Slurp of $size file\n\n" ;

# 	my $result = timethese( $dur, {

# 		new =>
# 	    		sub { my @lines = File::Slurp::read_file( $file_name ) },

# 		new_array_ref =>
# 	    		sub { my $lines_ref =
# 			     File::Slurp::read_file( $file_name, array_ref => 1 ) },

# 		new_in_anon_array =>
# 	    		sub { my $lines_ref =
# 			     [ File::Slurp::read_file( $file_name ) ] },

# 		read_file =>
# 	    		sub { my @lines = read_file( $file_name ) },

# 		sysread_file =>
# 	    		sub { my @lines = sysread_file( $file_name ) },

# 		orig_read_file =>
# 			sub { my @lines = orig_read_file( $file_name ) },

# 		'Slurp.pm to array' =>
# 			sub { my @lines = slurp_array( $file_name ) },

# 		orig_slurp_to_array_ref =>
# 			sub { my $lines_ref = orig_slurp_to_array( $file_name ) },
# 	} ) ;

# 	cmpthese( $result ) ;
# }


###########################
# write file benchmark subs
###########################



#######################
# top level subs for script

#######################

sub parse_options {

	my $result = GetOptions (\%opts, qw(
		iterations|i=s
		direction|d=s
		context|c=s
		sizes|s=s
		unlink|u
		legend|key|l|k
		help|usage
	) ) ;

	usage() unless $result ;

	usage() if $opts{help} ;

	legend() if $opts{legend} ;

# set defaults

	$opts{direction} ||= 'both' ;
	$opts{context} ||= 'both' ;
	$opts{iterations} ||= -2 ;
	$opts{sizes} ||= '500,10k,1m' ;

	if ( $opts{direction} eq 'both' ) {
	
		$opts{spew} = 1 ;
		$opts{slurp} = 1 ;
	}
	elsif ( $opts{direction} eq 'in' ) {

		$opts{slurp} = 1 ;
	
	}
	elsif ( $opts{direction} eq 'out' ) {

		$opts{spew} = 1 ;
	}
	else {

		usage( "Unknown direction: $opts{direction}" ) ;
	}

	if ( $opts{context} eq 'both' ) {
	
		$opts{list} = 1 ;
		$opts{scalar} = 1 ;
	}
	elsif ( $opts{context} eq 'scalar' ) {

		$opts{scalar} = 1 ;
	
	}
	elsif ( $opts{context} eq 'list' ) {

		$opts{list} = 1 ;
	}
	else {

		usage( "Unknown context: $opts{context}" ) ;
	}

	if ( $opts{context} eq 'both' ) {
	
		$opts{list} = 1 ;
		$opts{scalar} = 1 ;
	}
	elsif ( $opts{context} eq 'scalar' ) {

		$opts{scalar} = 1 ;
	
	}
	elsif ( $opts{context} eq 'list' ) {

		$opts{list} = 1 ;
	}
	else {

		usage( "Unknown context: $opts{context}" ) ;
	}

	foreach my $size ( split ',', ( $opts{sizes} ) ) {


# check for valid size and suffix. grab both.

		usage( "Illegal size: $size") unless $size =~ /^(\d+)([km])?$/ ;

# handle suffix multipliers

		$size =  $1 * (( $2 eq 'k' ) ? 1024 : 1024*1024) if $2 ;

		push( @{$opts{size_list}}, $size ) ;
	}

#use Data::Dumper ;
#print Dumper \%opts ;
}

sub legend {

	die <<'LEGEND' ;
Legend for the Slurp Benchmark Entries

In all cases below 'FS' or 'F::S' means the current File::Slurp module
is being used in the benchmark. The full name and description will say
which options are being used.

These benchmarks write a list of lines to a file. Use the direction option
of 'out' or 'both' and the context option is 'list' or 'both'.

	Key			Description/Source
	---			------------------
	FS::write_file		Current F::S write_file
	FS::write_file Aref	Current F::S write_file on array ref of data
	print			Open a file and call print() on the list data
	print/join		Open a file and call print() on the joined
				list data
	syswrite/join		Open a file, call syswrite on joined list data
	sysopen/syswrite	Sysopen a file, call syswrite on joined
				list data
	original write_file	write_file code from original File::Slurp
				(pre-version 9999.*)

These benchmarks write a scalar to a file. Use the direction option
of 'out' or 'both' and the context option is 'scalar' or 'both'.

	Key			Description/Source
	---			------------------
	FS::write_file		Current F::S write_file
	FS::write_file Sref	Current F::S write_file of scalar ref of data
	print			Open a file and call print() on the scalar data
	syswrite_file		Open a file, call syswrite on scalar data
	syswrite_file_ref	Open a file, call syswrite on scalar ref of data
	orig_write_file		write_file code from original File::Slurp
				(pre-version 9999.*)

These benchmarks slurp a file into an array. Use the direction option
of 'in' or 'both' and the context option is 'list' or 'both'.

FIX THIS

	Key			Description/Source
	---			------------------
	FS::write_file		Current F::S write_file
	FS::write_file Aref	Current F::S write_file on array ref of data
	print			Open a file and call print() on the list data
	print/join		Open a file and call print() on the joined
				list data
	syswrite/join		Open a file, call syswrite on joined list data
	sysopen/syswrite	Sysopen a file, call syswrite on joined
				list data
	original write_file	write_file code from original File::Slurp
				(pre-version 9999.*)

These benchmarks slurp a file into a scalar. Use the direction option
of 'in' or 'both' and the context option is 'scalar' or 'both'.

FIX THIS

	Key			Description/Source
	---			------------------
	FS::write_file		Current F::S write_file
	FS::write_file Aref	Current F::S write_file on array ref of data
	print			Open a file and call print() on the list data
	print/join		Open a file and call print() on the joined
				list data
	syswrite/join		Open a file, call syswrite on joined list data
	sysopen/syswrite	Sysopen a file, call syswrite on joined
				list data
	original write_file	write_file code from original File::Slurp
				(pre-version 9999.*)

LEGEND
}

sub usage {

	my( $err ) = @_ ;

	$err ||= '' ;

	die <<DIE ;
$err
Usage: $0 [--iterations=<iter>] [--direction=<dir>] [--context=<con>] 
          [--sizes=<size_list>] [--legend] [--help]

	--iterations=<iter>	Run the benchmarks this many iterations
	-i=<iter>		A positive number is iteration count,
				a negative number is minimum CPU time in
				seconds. Default is -2 (run for 2 CPU seconds).

	--direction=<dir>	Which direction to slurp: 'in', 'out' or 'both'.
	-d=<dir>		Default is 'both'.

	--context=<con>		Which context is used for slurping: 'list',
	-c=<con>		'scalar' or 'both'. Default is 'both'.

	--sizes=<size_list>	What sizes will be used in slurping (either
	-s=<size_list>		direction). This is a comma separated list of
				integers. You can use 'k' or 'm' as suffixes
				for 1024 and 1024**2. Default is '500,1k,1m'.

	--unlink		Unlink the written file before each time
	-u			a file is written

	--legend		Print out a legend of all the benchmark entries.
	--key
	-l
	-k

	--help			Print this help text
	--usage
DIE

}

__END__



sub bench_scalar_slurp {

	my ( $size ) = @_ ;

	print "\n\nScalar Slurp of $size file\n\n" ;

	my $buffer ;

	my $result = timethese( $dur, {

		new =>
	    		sub { my $text = File::Slurp::read_file( $file_name ) },

		new_buf_ref =>
	    		sub { my $text ;
			   File::Slurp::read_file( $file_name, buf_ref => \$text ) },
		new_buf_ref2 =>
	    		sub { 
			   File::Slurp::read_file( $file_name, buf_ref => \$buffer ) },
		new_scalar_ref =>
	    		sub { my $text =
			    File::Slurp::read_file( $file_name, scalar_ref => 1 ) },

		read_file =>
	    		sub { my $text = read_file( $file_name ) },

		sysread_file =>
	    		sub { my $text = sysread_file( $file_name ) },

		orig_read_file =>
			sub { my $text = orig_read_file( $file_name ) },

		orig_slurp =>
			sub { my $text = orig_slurp_to_scalar( $file_name ) },

		file_contents =>
			sub { my $text = file_contents( $file_name ) },

		file_contents_no_OO =>
			sub { my $text = file_contents_no_OO( $file_name ) },
	} ) ;

	cmpthese( $result ) ;
}

sub bench_list_slurp {

	my ( $size ) = @_ ;

	print "\n\nList Slurp of $size file\n\n" ;

	my $result = timethese( $dur, {

		new =>
	    		sub { my @lines = File::Slurp::read_file( $file_name ) },

		new_array_ref =>
	    		sub { my $lines_ref =
			     File::Slurp::read_file( $file_name, array_ref => 1 ) },

		new_in_anon_array =>
	    		sub { my $lines_ref =
			     [ File::Slurp::read_file( $file_name ) ] },

		read_file =>
	    		sub { my @lines = read_file( $file_name ) },

		sysread_file =>
	    		sub { my @lines = sysread_file( $file_name ) },

		orig_read_file =>
			sub { my @lines = orig_read_file( $file_name ) },

		orig_slurp_to_array =>
			sub { my @lines = orig_slurp_to_array( $file_name ) },

		orig_slurp_to_array_ref =>
			sub { my $lines_ref = orig_slurp_to_array( $file_name ) },
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
