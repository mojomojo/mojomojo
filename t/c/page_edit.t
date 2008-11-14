use Test::More ;
BEGIN{
$ENV{CATALYST_CONFIG}='t/var/mojomojo.yml';
$ENV{CATALYST_DEBUG}=0;
};
$ENV{MOJOMOJO_CONFIG}='t/app/mojomojo.yml';

BEGIN {
    eval "use Test::WWW::Mechanize::Catalyst 'MojoMojo'";
    my $catmech = ! $@;
    eval "use WWW::Mechanize::TreeBuilder";
    my $mech_treebuilder = ! $@;
    plan $catmech && $mech_treebuilder
    ? ( tests => 6 )
    : ( skip_all => 'needs Test::WWW::Mechanize::Catalyst and WWW::Mechanize::TreeBuilder for this test' ) ;
}

use_ok('MojoMojo::Controller::Page');

my $mech = Test::WWW::Mechanize::Catalyst->new;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

$mech->get_ok('http://localhost:3000/.login?login=admin&password=admin','Can log in ok');
$mech->get_ok('/.edit', 'can edit root page');
SKIP: {
    skip 'currently broken?', 3;
ok( $mech->look_down(
      _tag => 'input',
      name => 'parent',
      type => 'hidden',
      value => '' ), "root page has null parent in edit form");

$mech->get_ok('/help.edit', 'can edit help page');
ok( $mech->look_down(
      _tag => 'input',
      name => 'parent',
      type => 'hidden',
      value => '1' ), "help page has root parent in edit form");
};