use strict;
use warnings;
use IO::Handle ();

use File::Basename ();
use File::Spec ();
use lib File::Spec->catdir(File::Spec->rel2abs(File::Basename::dirname(__FILE__)), 'lib');
use FileSlurpTest qw(temp_file_path);

use File::Slurp qw(read_file write_file);

use Test::More;
plan tests => 6;

my $binmode;
for (':encoding(Latin-1)', ':crlf', ':raw') {
    $binmode = $_;

my $data = "\n\n\n";
my $file_name = temp_file_path();

stdio_write_file($file_name, $data);
my $slurped_data = read_file($file_name, { binmode => $binmode });

my $stdio_slurped_data = stdio_read_file( $file_name ) ;


print 'data ', unpack( 'H*', $data), "\n",
'slurp ', unpack('H*',  $slurped_data), "\n",
'stdio slurp ', unpack('H*',  $stdio_slurped_data), "\n";

is($data, $slurped_data, "slurp ($binmode)");

write_file($file_name, { binmode => $binmode }, $data );
$slurped_data = stdio_read_file($file_name);

is($data, $slurped_data, "spew ($binmode)");
unlink $file_name;

};

sub stdio_write_file {
    my ($file_name, $data) = @_;
    open (my $fh, '>', $file_name) || die "Couldn't create $file_name: $!";
    binmode $fh, $binmode;
    $fh->print($data);
}

sub stdio_read_file {
    my ($file_name) = @_;
    open (my $fh, '<', $file_name ) || die "Couldn't open $file_name: $!";
    binmode $fh, $binmode;
    local $/;
    my $data = <$fh>;
    return $data;
}
