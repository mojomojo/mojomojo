use Test::More tests => 2;
use_ok( Catalyst::Test, 'MojoMojo' );

ok( request('/')->is_success );
