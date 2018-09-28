use strict;
use warnings;

use File::Spec ();
use File::Slurp;
use File::Temp qw(tempfile);
use POSIX qw( :fcntl_h ) ;
use Test::More;

plan tests => 5;

# get the current position (BYTES)_
my $data_seek = tell(\*DATA);
ok($data_seek, 'tell: find position of __DATA__');

# first slurp in the lines
my @slurp_lines = read_file(\*DATA);
ok(@slurp_lines, 'read_file: list context - grabbed __DATA__');

# seek back to that inital BYTES position
my $res = seek(\*DATA, $data_seek, 0) || die "seek $!" ;
ok($res, 'seek: Move back to original __DATA__ position');
my @data_lines = <DATA>;
ok(@data_lines, 'readfile<>: list context - grabbed __DATA__');

is_deeply(\@slurp_lines, \@data_lines, 'both reads match');
exit;

__DATA__
line one
second line
more lines
still more

enough lines

we can't test long handle slurps from DATA since i would have to type
too much stuff

so we will stop here
