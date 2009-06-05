# common.pm - common test driver code

use Test::More ;

sub tester {

	my( $tests ) = @_ ;

use Data::Dumper ;

# plan for one expected ok() call per test

	plan( tests => scalar @{$tests} ) ;

# loop over all the tests

	foreach my $test ( @{$tests} ) {

#print Dumper $test ;


		if ( $test->{skip} ) {
			ok( 1, "SKIPPING $test->{name}" ) ;
			next ;
		}

# run any setup sub before this test. this can is used to modify the
# object for this test (e.g. delete templates from the cache).

		if( my $pretest = $test->{pretest} ) {

			$pretest->($test) ;
		}

		my $sub = $test->{sub} ;
		my $args = $test->{args} ;

		my $result = eval {
			$sub->( @{$args} ) ;
		} ;

# if we had an error and expected it, we pass this test

		if ( $@ ) {

			if ( $test->{error} && $@ =~ /$test->{error}/ ) {

				ok( 1, $test->{name} ) ;
			}
			else {

				print "unexpected error: $@\n" ;
				ok( 0, $test->{name} ) ;
			}
		}

		if( my $posttest = $test->{posttest} ) {

			$posttest->($test) ;
		}
	}
}

1 ;
