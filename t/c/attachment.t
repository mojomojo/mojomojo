use Test::More tests => 3;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::C::Attachment');

ok( request('attachment')->is_success );
