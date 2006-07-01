use Test::More tests => 2;
$ENV{CATALYST_DEBUG}=0;
use_ok( Catalyst::Test, 'MojoMojo' );

ok( request('/')->is_success );
