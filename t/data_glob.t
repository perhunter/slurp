use strict;
use warnings;

use File::Basename ();
use File::Spec ();
use lib File::Spec->catdir(File::Spec->rel2abs(File::Basename::dirname(__FILE__)), 'lib');
use FileSlurpTest qw(trap_function);
use File::Slurp qw(read_file);

# a package with a __DATA__ section
use FSGlobby ();

use Scalar::Util qw(blessed);
use Symbol qw(qualify qualify_to_ref);
use Test::More;

plan tests => 9;

my $obj = FSGlobby->new();
ok(defined $obj, "Constructor returned defined object");
isa_ok( $obj, 'FSGlobby');

my $symbolname = qualify("DATA", blessed $obj);
is($symbolname, 'FSGlobby::DATA', "Symbol::qualify(): Got expected symbol name");

my $glob = qualify_to_ref("DATA", blessed $obj);
is(ref($glob), 'GLOB', "Symbol::qualify_to_ref():  Got a glob");

my @lines = read_file($glob, {chomp => 1});
my $expected_lines = 8;
is(scalar @lines, $expected_lines, "Got $expected_lines lines in file");
is($lines[0], 'File:', "Got expected first line");
is($lines[$expected_lines - 1], 'Last-Updated:', "Got expected last line");
my %lines_seen;
map { $lines_seen{$_}++ } @lines;
is($lines_seen{$lines[0]}, 1, "First line seen exactly once");
is($lines_seen{$lines[$expected_lines - 1]}, 1, "Last line seen exactly once");
