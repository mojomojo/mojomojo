#!/usr/bin/perl -w
use Test::More ;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
};

BEGIN {
    eval "use Test::WWW::Mechanize::Catalyst 'MojoMojo'";
    plan skip_all => 'need Test::WWW::Mechanize::Catalyst' if $@;

    eval "use WWW::Mechanize::TreeBuilder";
    plan skip_all => 'need WWW::Mechanize::TreeBuilder' if $@;

    plan tests => 8;
}

use_ok('MojoMojo::Controller::Page');

my $mech = Test::WWW::Mechanize::Catalyst->new;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

my ($elem);

$mech->post('/.login', {
    login => 'admin',
    pass => 'admin'
});
ok $mech->success, 'logging in as admin';

ok(($elem) = $mech->look_down(
   _tag => 'a',
   'href' => qr'/admin$'
), 'admin link');
if ($elem) {
    is $elem->as_trimmed_text, 'admin', 'logged in as admin';
}

$mech->get_ok('/.edit', 'can edit root page');

ok( $mech->look_down(
    _tag => 'input',
    name => 'parent',
    type => 'hidden',
    value => ''
), "root page has null parent in edit form");

$mech->get_ok('/help.edit', 'can edit help page');
ok( $mech->look_down(
    _tag => 'input',
    name => 'parent',
    type => 'hidden',
    value => '1'
), "help page has root parent in edit form");
