use Test::More tests => 3;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::C::User');

ok( request('user')->is_success );
