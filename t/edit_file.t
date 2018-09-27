
use strict ;
use warnings ;

use lib qw(t) ;

use File::Slurp qw( read_file write_file edit_file ) ;
use Test::More ;

use TestDriver ;

my $file = 'edit_file' ;
my $existing_data = <<PRE ;
line 1
line 2
more
PRE

my $tests = [
    {
		name	=> 'edit line',
		sub	=> \&edit_file,
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				sub { s/([0-9])/${1}000/g },
				$file,
			] ;
			$test->{expected} = join("\n" => (
                'line 1000',
                'line 2000',
                'more',
            ) ) . "\n";
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
    {
		name	=> 'edit line; empty options hashref',
		sub	=> \&edit_file,
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				sub { s/([0-9])/${1}000/g },
				$file,
                {},
			] ;
			$test->{expected} = join("\n" => (
                'line 1000',
                'line 2000',
                'more',
            ) ) . "\n";
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
    {
		name	=> 'edit line; invalid options',
		sub	=> \&edit_file,
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				sub { s/([0-9])/${1}000/g },
				$file,
                { foo => 1, bar => 0 },
			] ;
			$test->{expected} = join("\n" => (
                'line 1000',
                'line 2000',
                'more',
            ) ) . "\n";
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
    {
		name	=> 'edit line; invalid options; binmode',
		sub	=> \&edit_file,
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				sub { s/([0-9])/${1}000/g },
				$file,
                { foo => 1, bar => 0, binmode => ':raw' },
			] ;
			$test->{expected} = join("\n" => (
                'line 1000',
                'line 2000',
                'more',
            ) ) . "\n";
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
    {
		name	=> 'edit line; invalid options; err_mode',
		sub	=> \&edit_file,
		pretest	=> sub {
			my( $test ) = @_ ;
			write_file( $file, $existing_data ) ;
			$test->{args} = [
				sub { s/([0-9])/${1}000/g },
				$file,
                { foo => 1, bar => 0, err_mode => 'quiet' },
			] ;
			$test->{expected} = join("\n" => (
                'line 1000',
                'line 2000',
                'more',
            ) ) . "\n";
		},
		posttest => sub { $_[0]->{result} = read_file( $file ) },
	},
] ;

test_driver( $tests ) ;
unlink $file ;

exit ;
