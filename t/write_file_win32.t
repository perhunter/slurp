use strict;
use File::Slurp ;

use Test::More tests => 1;

BEGIN { $^W = 1 }

sub simple_write_file {
    open my $fh, '>', $_[0] or die "Couldn't open $_[0] for write: $!";
    print $fh $_[1];
}

sub newline_size {
    my ($code) = @_;

    my $file = __FILE__ . '.tmp';

    local $\ = '';
    $code->($file, "\n" x 3);

    my $size = -s $file;

    unlink $file;

    return $size;
}

is(newline_size(\&write_file), newline_size(\&simple_write_file), 'newline');
