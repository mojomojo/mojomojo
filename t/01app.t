use Test::More tests => 2;
use lib qw(t/lib);
use MojoMojoTestSchema;
$ENV{CATALYST_DEBUG}=0;
$ENV{CATALYST_CONFIG}='t/var/mojomojo.yml';
MojoMojoTestSchema->init_schema(no_populate => 0);  # 'created a test schema object'
use_ok( Catalyst::Test, 'MojoMojo' );
ok( request('/')->is_success );
