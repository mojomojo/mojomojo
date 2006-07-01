use Test::More tests => 2;
$ENV{CATALYST_DEBUG}=0;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Journal');

#ok( request('/.journal')->is_success );
