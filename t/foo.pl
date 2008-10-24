#!/usr/local/bin/perl


                sub pipe_from_fork ($) {
                     my $parent = shift;
                     pipe $parent, my $child or die;
                     my $pid = fork();
                     die "fork() failed: $!" unless defined $pid;
                     if ($pid) {
                         close $child;
                     }
                     else {
                         close $parent;
                         open(STDOUT, ">&=" . fileno($child)) or die;
                     }
                     $pid;
                 }

                 if (pipe_from_fork('BAR')) {
                     # parent
                     while (<BAR>) { print; }
                     close BAR;
                 }
                 else {
                     # child
                     print "pipe_from_fork\n";
                     close STDOUT;
                     exit(0);
                 }

