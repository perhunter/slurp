use strict;
use warnings;

use File::Spec ();
use File::Slurp;
use File::Temp qw(tempfile);
use Test::More;

plan(tests => 3);

my (undef, $file) = tempfile('tempXXXXX', DIR => File::Spec->tmpdir, OPEN => 0);
my $data = <<TEXT ;
line 1
more text
TEXT

my $res = write_file($file, $data);
ok($res, 'write_file: text data');
$res = append_file($file, '');
ok($res, 'append_file: no data');

my $text = read_file($file);
is($text, $data, 'read_file: scalar context');

unlink $file;
