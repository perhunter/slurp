#!/usr/local/bin/perl
 sub pipe_to_fork ($) {
                     my $parent = shift;
                     pipe my $child, $parent or die;
                     my $pid = fork();
                     die "fork() failed: $!" unless defined $pid;
                     if ($pid) {
                         close $child;
                     }
                     else {
                         close $parent;
                         open(STDIN, "<&=" . fileno($child)) or die;
                     }
                     $pid;
                 }

                 if (pipe_to_fork('FOO')) {
                     # parent
                     print FOO "pipe_to_fork\n";
                     close FOO;
                 }
                 else {
                     # child
                     while (<STDIN>) { print; }
                     close STDIN;
                     exit(0);
                 }
