use Test::More tests => 3;
$ENV{CATALYST_DEBUG}=0;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::User');

ok( request('user')->is_success );
