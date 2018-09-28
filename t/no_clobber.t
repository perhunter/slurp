use strict;
use warnings;

use File::Spec ();
use File::Slurp;
use File::Temp qw(tempfile);
use Test::More;

plan(tests => 6);

my (undef, $file) = tempfile('tempXXXXX', DIR => File::Spec->tmpdir, OPEN => 0);

my $data = <<TEXT ;
line 1
more text
TEXT

{
    my $res;
    my $warn;
    my $err = do { # catch
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        eval { # try
            $res = write_file($file, {no_clobber => 1,}, $data);
            1;
        };
        $@;
    };
    ok($res, 'write_file: no_clobber opt - new file');
    ok(!$warn, 'write_file: no_clobber opt - new file - no warnings!');
    ok(!$err, 'write_file: no_clobber opt - new file - no exceptions!');
}

{
    my $res;
    my $warn;
    my $err = do { # catch
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        eval { # try
            $res = write_file($file, {no_clobber => 1, err_mode=>'quiet',}, $data);
            1;
        };
        $@;
    };
    ok(!$res, 'write_file: no_clobber, err_mode quiet opts - existing file - no added content');
    ok(!$warn, 'write_file: no_clobber, err_mode quiet opts - existing file - no warnings!');
    ok(!$err, 'write_file: no_clobber, err_mode quiet opts - existing file - no exceptions!');
}

unlink $file ;
