use strict;
use warnings;

# this test was generated with Dist::Zilla::Plugin::Test::EOL 0.19

use Test::More 0.88;
use Test::EOL;

my @files = (
    'lib/File/Slurp.pm',
    't/append_null.t',
    't/binmode.t',
    't/data_list.t',
    't/data_scalar.t',
    't/error.t',
    't/error_mode.t',
    't/file_object.t',
    't/handle.t',
    't/inode.t',
    't/large.t',
    't/newline.t',
    't/no_clobber.t',
    't/original.t',
    't/paragraph.t',
    't/perms.t',
    't/prepend_file.t',
    't/pseudo.t',
    't/read_dir.t',
    't/slurp.t',
    't/stdin.t',
    't/stringify.t',
    't/tainted.t',
    't/TestDriver.pm',
    't/write_file_win32.t',
);

eol_unix_ok($_, { trailing_whitespace => 1 }) foreach @files;
done_testing;
