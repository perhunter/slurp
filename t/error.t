##!/usr/local/bin/perl -w

use lib qw(t) ;

use strict ;
use File::Slurp qw( :all ) ;

use common ;

my $file_name = 'test_file' ;
my $dir_name = 'test_dir' ;

my $tests = [

	{
		name	=> 'read_file open error',
		sub	=> \&read_file,
		args	=> [ $file_name ],

		error => qr/open/,
	},

	{
		name	=> 'write_file open error',
		sub	=> \&write_file,
		args	=> [ "$dir_name/$file_name", '' ],
		pretest => sub {
			mkdir $dir_name ;
			chmod( 0555, $dir_name ) ;
		},

		posttest => sub {

			chmod( 0777, $dir_name ) ;
			rmdir $dir_name ;
		},

		error => qr/open/,
	},

	{
		name	=> 'atomic rename error',
		sub	=> \&write_file,
		args	=> [ "$dir_name/$file_name", { atomic => 1 }, '' ],
		pretest => sub {
			mkdir $dir_name ;
			write_file( "$dir_name/$file_name.$$", '' ) ;
			chmod( 0555, $dir_name ) ;
		},

		posttest => sub {

			chmod( 0777, $dir_name ) ;
			unlink( "$dir_name/$file_name.$$" ) ;
			rmdir $dir_name ;
		},

		error => qr/rename/,
	},

	{
		name	=> 'read_dir open error',
		sub	=> \&read_dir,
		args	=> [ $dir_name ],

		error => qr/open/,
	},

] ;

tester( $tests ) ;

exit ;

