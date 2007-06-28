use Test::More tests => 2;
$ENV{CATALYST_DEBUG}=0;
use_ok( Catalyst::Test, 'MojoMojo' );

do MojoMojo->path_to('script','mojomojo_spawn_db.pl') 
  unless -f MojoMojo->path_to('mojomojo.db');
ok( request('/')->is_success );
