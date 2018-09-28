use strict;
use warnings;

use Carp;
use File::Spec ();
use File::Slurp;
# use File::Temp qw(tempfile);
use IO::Handle ();
use Test::More;

plan tests => 27;

{ # read_dir errors
    # this one intentionally doesn't exist on a couple of paths. can't be created.
    my $file = File::Spec->catfile(File::Spec->tmpdir, 'super', 'bad', 'file-spec', 'path');
    my ($res, $warn, $err) = trap_read_dir($file, 'quiet');
    ok(!$warn, 'read_dir: err_mode opt quiet - no warn!');
    ok(!$err, 'read_dir: err_mode opt quiet - no exception!');
    ok(!$res, 'read_dir: err_mode opt quiet - no content!');
    ($res, $warn, $err) = trap_read_dir($file, 'carp');
    ok($warn, 'read_dir: err_mode opt carp - got warn!');
    ok(!$err, 'read_dir: err_mode opt carp - no exception!');
    ok(!$res, 'read_dir: err_mode opt carp - no content!');
    ($res, $warn, $err) = trap_read_dir($file, 'croak');
    ok(!$warn, 'read_dir: err_mode opt croak - no warn!');
    ok($err, 'read_dir: err_mode opt croak - got exception!');
    ok(!$res, 'read_dir: err_mode opt croak - no content!');
}

{ # read_file errors
    # this one intentionally doesn't exist on a couple of paths. can't be created.
    my $file = File::Spec->catfile(File::Spec->tmpdir, 'super', 'bad', 'file-spec', 'path');
    my ($res, $warn, $err) = trap_read_file($file, 'quiet');
    ok(!$warn, 'read_file: err_mode opt quiet - no warn!');
    ok(!$err, 'read_file: err_mode opt quiet - no exception!');
    ok(!$res, 'read_file: err_mode opt quiet - no content!');
    ($res, $warn, $err) = trap_read_file($file, 'carp');
    ok($warn, 'read_file: err_mode opt carp - got warn!');
    ok(!$err, 'read_file: err_mode opt carp - no exception!');
    ok(!$res, 'read_file: err_mode opt carp - no content!');
    ($res, $warn, $err) = trap_read_file($file, 'croak');
    ok(!$warn, 'read_file: err_mode opt croak - no warn!');
    ok($err, 'read_file: err_mode opt croak - got exception!');
    ok(!$res, 'read_file: err_mode opt croak - no content!');
}

{ # write_file errors
    # this one intentionally doesn't exist on a couple of paths. can't be created.
    my $file = File::Spec->catfile(File::Spec->tmpdir, 'super', 'bad', 'file-spec', 'path');
    my ($res, $warn, $err) = trap_write_file($file, 'quiet');
    ok(!$warn, 'write_file: err_mode opt quiet - no warn!');
    ok(!$err, 'write_file: err_mode opt quiet - no exception!');
    ok(!$res, 'write_file: err_mode opt quiet - no content!');
    ($res, $warn, $err) = trap_write_file($file, 'carp');
    ok($warn, 'write_file: err_mode opt carp - got warn!');
    ok(!$err, 'write_file: err_mode opt carp - no exception!');
    ok(!$res, 'write_file: err_mode opt carp - no content!');
    ($res, $warn, $err) = trap_write_file($file, 'croak');
    ok(!$warn, 'write_file: err_mode opt croak - no warn!');
    ok($err, 'write_file: err_mode opt croak - got exception!');
    ok(!$res, 'write_file: err_mode opt croak - no content!');
}

sub trap_read_dir {
    my ($file, $mode) = @_;
    my $res;
    my $warn;
    my $err = do { # catch
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        eval { # try
            $res = read_dir($file, err_mode => $mode);
            1;
        };
        $@;
    };
    return ($res, $warn, $err);
}

sub trap_read_file {
    my ($file, $mode) = @_;
    my $res;
    my $warn;
    my $err = do { # catch
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        eval { # try
            $res = read_file($file, err_mode => $mode);
            1;
        };
        $@;
    };
    return ($res, $warn, $err);
}

sub trap_write_file {
    my ($file, $mode) = @_;
    my $res;
    my $warn;
    my $err = do { # catch
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        eval { # try
            $res = write_file($file, {err_mode => $mode}, 'junk');
            1;
        };
        $@;
    };
    return ($res, $warn, $err);
}
