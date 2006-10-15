use Test::More tests => 6;
$ENV{CATALYST_DEBUG}=0;
$ENV{MOJOMOJO_CONFIG}='t/app/mojomojo.yml';
use_ok( Catalyst::Test, 'MojoMojo' );
use_ok('MojoMojo::Controller::Page');

my $root_edit = request('/.edit');
ok( $root_edit->is_success, 'can edit root page');
like( $root_edit->content, qr{<input\s+value=""\s+name="parent"\s+type="hidden"\s+/>}, "root page has null parent in edit form");
my $help_edit = request('/help.edit');
ok( $help_edit->is_success, 'can edit help page');
like( $help_edit->content, qr{<input\s+value="1"\s+name="parent"\s+type="hidden"\s+/>}, "help page has root parent in edit form");
