use Test::More tests => 5;
$ENV{CATALYST_DEBUG}=0;
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Jsrpc');

my $req = request('/.jsrpc/render?content=123');
ok( $req->is_success );
is( $req->content, '<p>123</p>','correct body returned' );
ok( request('/.jsrpc/child_menu')->is_success );