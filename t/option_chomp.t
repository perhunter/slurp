# Purpose: Test the chomp option while reading files
use strict;
use warnings;

use File::Basename ();
use File::Spec ();
use lib File::Spec->catdir(File::Spec->rel2abs(File::Basename::dirname(__FILE__)), 'lib');
use FileSlurpTest qw(temp_file_path);

use File::Slurp qw(read_file write_file);
use Test::More;

# -------- Prelude: Set up expected data and write a data file
my $expected = <<TEXT;
PREFACE

All in the golden afternoon
    Full leisurely we glide;
For both our oars, with little skill,
    By little arms are plied,
While little hands make vain pretence
    Our wanderings to guide.

-- Lewis Carroll, Alice in Wonderland
TEXT

my @expected_lines = $expected =~ /(.*\n)/mg;
chomp (my @expected_chomped = @expected_lines);

my ($array_ref,$scalar_ref);

my $file = temp_file_path();
{
    open my $fh, ">", $file or die "Couldn't open $file for write: $!";
    $fh->print($expected);
}

# -------- Run the tests
{
    local $/ = 'a';
    my $got = read_file($file, {chomp => 1});
    is($got,$expected,"scalar context, no chomping");
}

{
    my @got = read_file($file);
    is_deeply(\@got,\@expected_lines, "list context, chomp not provided");
}

{
    my @got = read_file($file, { chomp => 0 });
    is_deeply(\@got,\@expected_lines, "list context, chomp => 0");
}

{
    my @got = read_file($file, chomp => 1);
    is_deeply(\@expected_chomped,\@got, "list context, chomp => 1, option as flat hash");
}

{
    my @got = read_file($file, {chomp => 1});
    is_deeply(\@expected_chomped,\@got, "list context, chomp => 1, option as hashref");
}

{
    local $/ = '';
    my @got = read_file($file, {chomp => 1});
    is(scalar @got,3,"paragraph mode splits into three paragraphs");
    isnt(substr($got[2],-1,1),"\n","paragraph mode chomps trailing line feed");
}

{
    local $/;
    my @got = read_file($file, {chomp => 1});
    is(scalar @got,1,'slurp mode by undefined $/ yields one "line"');
    is($got[0],$expected,"slurp mode by undefined \$/ doesn't chomp");
}

# read_file doesn't handle fixed record lengths
# {
#     local $/ = \24;
#     my @got = read_file($file, {chomp => 0});
#     is(scalar @got,10,"fixed record mode, ten paragraphs");
#     my $in_data = join '', @got;
#     is($in_data,$expected,"fixed record mode, no chomping");
# }




done_testing;
