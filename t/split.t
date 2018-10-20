use strict;
use warnings;

use File::Basename ();
use File::Spec ();
use lib File::Spec->catdir(File::Spec->rel2abs(File::Basename::dirname(__FILE__)), 'lib');
use FileSlurpTest qw(temp_file_path);

use File::Slurp qw(slurp write_file);
use Test::More;

plan tests => 1;

my $data = <<TEXT;
line 1{{{{more text
TEXT

my $file = temp_file_path();

$data =~ s!\s*$!!;

write_file($file, $data);

$/ = '{{{{';

my @lines = slurp($file);
is_deeply(\@lines, ['line 1{{{{', 'more text'], 'slurp multiline regex');

unlink $file ;
