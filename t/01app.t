use Test::More tests => 2;
$ENV{CATALYST_DEBUG}=0;
$ENV{CATALYST_CONFIG}='t/var/mojomojo.yml';
use_ok( Catalyst::Test, 'MojoMojo' );

do MojoMojo->path_to('script','mojomojo_spawn_db.pl') 
  unless -f MojoMojo->path_to('t/var/mojomojo.db');
ok( request('/')->is_success );
