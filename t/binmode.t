#!/usr/local/bin/perl -w

use strict ;
use Test::More ;
use Carp ;
use File::Slurp ;

if ( $] < 5.008001 ) {
        plan skip_all => 'Older Perl lacking unicode support' ;
	exit ;
}

plan tests => 2 ;

my $mode = ':utf8' ;

my $orig_text = "\x{20ac}\n" ;
my $unicode_length = length $orig_text ;

my $control_file = "control.$mode" ;
my $slurp_file = "slurp.$mode" ;

open( my $fh, ">$mode", $control_file ) or
	die "cannot create control unicode file '$control_file' $!" ;
print $fh $orig_text ;
close $fh ;

my $slurp_utf = read_file( $control_file, binmode => $mode ) ;
ok( $slurp_utf eq $orig_text, "read_file of $mode file" ) ;

# my $slurp_utf_length = length $slurp_utf ;
# my $slurp_text = read_file( $control_file ) ;
# my $slurp_text_length = length $slurp_text ;
# print "LEN UTF $slurp_utf_length TXT $slurp_text_length\n" ;

write_file( $slurp_file, {binmode => $mode}, $orig_text ) ;

open( $fh, "<$mode", $slurp_file ) or
	die "cannot open slurp test file '$slurp_file' $!" ;
my $read_length = read( $fh, my $utf_text, $unicode_length ) ;
close $fh ;

ok( $utf_text eq $orig_text, "write_file of $mode file" ) ;

unlink( $control_file, $slurp_file ) ;
