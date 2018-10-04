package FileSlurpTest;

use strict;
use warnings;
use Exporter qw(import);
use IO::Handle ();
use File::Spec ();
use File::Temp qw(tempfile);

BEGIN {
    *CORE::GLOBAL::rename = sub($$) { my ($o, $n) = @_; CORE::rename($o, $n) };
    # we only use the 4-arg version of syswrite
    *CORE::GLOBAL::syswrite = sub($$;$$) { my ($h, $buff, $l, $o) = @_; return CORE::syswrite($h, $buff, $l, $o); };
    # We use the 3 and 4-arg form of sysread.
    *CORE::GLOBAL::sysread = \&CORE::sysread;
            # sub($$$;$) { my( $h, $b, $s, $o ) = @_; CORE::sysread $h, $b, $s, $o } ;
    # We use the 3 and 4-arg form of sysopen
    *CORE::GLOBAL::sysopen = \&CORE::sysopen;
    # sub(*$$;$) {
    #     my ($h, $n, $m, $p) = @_;
    #     return CORE::sysopen($h, $n, $m, $p) if defined $p;
    #     CORE::sysopen($h, $n, $m);
    # };
}

use File::Slurp ();

our @EXPORT_OK = qw(
    IS_WSL temp_file_path trap_function trap_function_list_context
    trap_function_override_core
);

sub IS_WSL() {
  if ($^O eq 'linux') {
    require POSIX;
    return 1 if (POSIX::uname())[2] =~ /windows/i;
  }
}

sub temp_file_path {
    my ($pick_nonsense_path) = @_;

    my $file;
    if ($pick_nonsense_path) {
        $file = File::Spec->catfile(File::Spec->tmpdir, 'super', 'bad', 'file-spec', 'path');
    }
    else {
        (undef, $file) = tempfile('tempXXXXX', DIR => File::Spec->tmpdir, OPEN => 0);
    }
    return $file;
}

sub trap_function {
    my ($function, @args) = @_;
    my $res;
    my $warn;
    my $err = do { # catch
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        eval { # try
            $res = $function->(@args);
            1;
        };
        $@;
    };
    return ($res, $warn, $err);
}

sub trap_function_list_context {
    my ($function, @args) = @_;
    my @res;
    my $warn;
    my $err = do { # catch
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        eval { # try
            @res = $function->(@args);
            1;
        };
        $@;
    };
    return (\@res, $warn, $err);
}

sub trap_function_override_core {
    my ($core, $function, @args) = @_;

    my $res;
    my $warn;
    my $err = do { # catch
        no strict 'refs';
        no warnings;
        local $^W;
        local $@;
        local $SIG{__WARN__} = sub {$warn = join '', @_};
        local *{"CORE::GLOBAL::$core"} = sub {};
        eval { # try
            $res = $function->(@args);
            1;
        };
        $@;
    };

    return ($res, $warn, $err);
}

1;
