#!/usr/local/bin/perl

print tell(\*DATA), "\n" ;
print sysseek(\*DATA, 0, 1), "\n" ;

my $read_cnt = sysread( \*DATA, $buf, 1000 ) ;
print "CNT $read_cnt\n[$buf]\n" ;

my $read_cnt = sysread( *DATA, $buf, 1000 ) ;
print "CNT $read_cnt\n[$buf]\n" ;

open( FOO, "<&DATA" ) || die "reopen $!" ;


my $read_cnt = sysread( \*FOO, $buf, 1000 ) ;
print "CNT $read_cnt\n[$buf]\n" ;

my $read_cnt = read( \*FOO, $buf, 1000 ) ;
print "CNT $read_cnt\n[$buf]\n" ;

@lines = <DATA> ;
print "lines [@lines]\n" ;


__END__
line 1
foo bar

