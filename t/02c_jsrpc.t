use Test::More tests => 3;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::C::Jsrpc');

ok( request('jsrpc')->is_success );
