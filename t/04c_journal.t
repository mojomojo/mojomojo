use Test::More tests => 3;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::C::Journal');

ok( request('journal')->is_success );
