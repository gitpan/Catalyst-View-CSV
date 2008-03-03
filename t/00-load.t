#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Catalyst::View::CSV' );
}

diag( "Testing Catalyst::View::CSV $Catalyst::View::CSV::VERSION, Perl $], $^X" );
