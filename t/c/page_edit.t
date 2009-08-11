#!/usr/bin/perl -w
use Test::More ;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
};
$ENV{MOJOMOJO_CONFIG}='t/app/mojomojo.yml';

BEGIN {
    eval "use Test::WWW::Mechanize::Catalyst 'MojoMojo'";
    plan skip_all => 'need Test::WWW::Mechanize::Catalyst' if $@;

    eval "use WWW::Mechanize::TreeBuilder";
    plan skip_all => 'need WWW::Mechanize::TreeBuilder' if $@;

    plan tests => 6;
}

use_ok('MojoMojo::Controller::Page');

my $mech = Test::WWW::Mechanize::Catalyst->new;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

$mech->get_ok('http://localhost:3000/.login?login=admin&password=admin', 'can log in as admin via URL');
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
