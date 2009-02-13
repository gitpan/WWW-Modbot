#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'WWW::Modbot' );
}

diag( "Testing WWW::Modbot $WWW::Modbot::VERSION, Perl $], $^X" );
