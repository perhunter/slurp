##!/usr/local/bin/perl -w

use lib qw(t) ;
use strict ;
use driver ;

use File::Slurp qw( :all ) ;

my $file_name = 'test_file' ;
my $dir_name = 'test_dir' ;

my $tests = [

	{
		name	=> 'read_file open error',
		sub	=> \&read_file,
		args	=> [ $file_name ],

		error => qr/open/,

		skip	=> 1,
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
		skip	=> 1,
	},

	{
		name	=> 'write_file syswrite error',
		sub	=> \&write_file,
		args	=> [ $file_name, '' ],
		override	=> 'syswrite',

		posttest => sub {
			unlink( $file_name ) ;
		},


		error => qr/write/,
		skip	=> 1,
	},

	{
		name	=> 'read_file small sysread error',
		sub	=> \&read_file,
		args	=> [ $file_name ],
		override	=> 'sysread',

		pretest => sub {
			write_file( $file_name, '' ) ;
		},

		posttest => sub {
			unlink( $file_name ) ;
		},


		error => qr/read/,
	},

	{
		name	=> 'read_file loop sysread error',
		sub	=> \&read_file,
		args	=> [ $file_name ],
		override	=> 'sysread',

		pretest => sub {
			write_file( $file_name, 'x' x 100_000 ) ;
		},

		posttest => sub {
			unlink( $file_name ) ;
		},


		error => qr/read/,
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
		skip	=> 1,
	},

	{
		name	=> 'read_dir opendir error',
		sub	=> \&read_dir,
		args	=> [ $dir_name ],

		error => qr/open/,
		skip	=> 1,
	},
] ;

test_driver( $tests ) ;

exit ;

