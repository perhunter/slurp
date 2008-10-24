#!/usr/local/bin/perl

use Fcntl qw( :seek ) ;
my $tell = tell( \*DATA );
my $sysseek = sysseek( \*DATA, 0, SEEK_CUR ) ;

print "TELL $tell SYSSEEK $sysseek\n" ;

__DATA__
foo
bar

