use Test::More tests => 2 + 1;
use strict;
BEGIN { $^W = 1 }

BEGIN {
    require_ok('File::Slurp');
    use_ok('File::Slurp', 'write_file');
}


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
