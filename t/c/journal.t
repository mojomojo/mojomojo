use Test::More tests => 2;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Journal');

#ok( request('/.journal')->is_success );
