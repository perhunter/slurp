#!/usr/local/bin/perl


use Carp ;

$carp = shift ;

( ( $carp eq 'carp' ) ? \&carp : \&croak )->( "can't open file\n ) ;

print "ok\n" ;
