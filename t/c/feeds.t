use Test::More tests => 3;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::C::Feeds');

ok( request('feeds')->is_success );
