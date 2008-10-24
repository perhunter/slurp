#!/usr/local/bin/perl

use strict ;

use Benchmark qw( timethese cmpthese ) ;

my $dur = shift || -2 ;

my $data = 'abc' x 30 . "\n"  x 1000 ;

my $sep = $/ ;

# my $result = timethese( $dur, {
# 		split => 'my @lines = splitter()',
# 		regex => 'my @lines = regex()',
# 		damian => 'my @lines = damian()',
# } ) ;

# cmpthese( $result ) ;

$data = "abcdefgh\n\n\n" x 5 ;
$data = "abcdefgh\n" x 2 . 'z' ;

$data = '' ;

#$sep = '\n\n+' ;
$sep = '\n' ;

my @paras ;

@paras = regex() ;
print "REG\n", map "[$_]\n", @paras ;

#@paras = damian() ;
#print "DAM\n", map "[$_]\n", @paras ;

sub splitter { split( m|(?<=$sep)|, $data ) }
sub regex { $data =~ /(.*?$sep|.*)/sg }
sub damian { $data =~ /.*?(?:$sep|\Z)/gs }


exit ;
