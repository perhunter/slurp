use strict;
use warnings;

use File::Spec ();
use File::Slurp;
use File::Temp qw(tempfile);
use IO::Handle ();
use POSIX qw( :fcntl_h ) ;
use Test::More;

plan tests => 5;

# get the current position (BYTES)_
my $data_seek = tell(\*DATA);
ok($data_seek, 'tell: find position of __DATA__');

# first slurp in the text
my $slurp_text = read_file(\*DATA);
ok($slurp_text, 'read_file: scalar context - grabbed __DATA__');

# now we need to get the golden data
# seek back to that inital BYTES position
my $res = seek(\*DATA, $data_seek, 0) || die "seek $!" ;
ok($res, 'seek: Move back to original __DATA__ position');
my $data_text = join('', <DATA>);
ok($data_text, 'readfile<>: list context, joined - grabbed __DATA__');

is($slurp_text, $data_text, 'both reads match');

exit();

__DATA__
line one
second line
more lines
still more

enough lines

we can't test long handle slurps from DATA since i would have to type
too much stuff

so we will stop here
