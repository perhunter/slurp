# driver.pm - common test driver code

use Test::More ;

BEGIN {
	*CORE::GLOBAL::syswrite =
	sub(*\$$;$) { my( $h, $b, $s ) = @_; CORE::syswrite $h, $b, $s } ;

	*CORE::GLOBAL::sysread =
	sub(*\$$;$) { my( $h, $b, $s ) = @_; CORE::sysread $h, $b, $s } ;
}

sub test_driver {

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

		my $override = $test->{override} ;

# run any setup sub before this test. this can is used to modify the
# object for this test (e.g. delete templates from the cache).

		if( my $pretest = $test->{pretest} ) {

			$pretest->($test) ;
		}

		my $sub = $test->{sub} ;
		my $args = $test->{args} ;

local( $^W) ;
		local *{"CORE::GLOBAL::$override"} = sub {} if $override ;

		my $result = eval {
			$sub->( @{$args} ) ;
		} ;

# if we had an error and expected it, we pass this test

		if ( $@ ) {

			if ( $test->{error} && $@ =~ /$test->{error}/ ) {

				ok( 1, $test->{name} ) ;
#print "ERR [$@]\n" ;
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
