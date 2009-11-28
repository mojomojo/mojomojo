#!/usr/bin/perl -w
use Test::More;
BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
};

BEGIN {
    eval "use Test::WWW::Mechanize::Catalyst 'MojoMojo'";
    plan skip_all => 'need Test::WWW::Mechanize::Catalyst' if $@;

    eval "use WWW::Mechanize::TreeBuilder";
    plan skip_all => 'need WWW::Mechanize::TreeBuilder' if $@;

    plan tests => 25;
};

use_ok('MojoMojo::Extensions::Counter');

my $elem;
my $mech = Test::WWW::Mechanize::Catalyst->new;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

$mech->get('/special/counter');
ok $mech->success, 'testing a simple get';
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'counter display');
if ($elem) {
    is $elem->as_trimmed_text, 0, 'checking that counter starts at 0';
}

$mech->get_ok('/special/counter.add', 'checking the add controller');
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'checking that the counter has been incremented');
if($elem) {
    is $elem->as_trimmed_text, 1, 'checking the counter update';
}

$mech->get_ok('/special/counter.add', 'checking the counter again');
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'checking that the counter has been incremented again');
if($elem) {
    is $elem->as_trimmed_text, 2, 'checking the counter update again';
}

$mech->get_ok('/special/counter', 'checking the persistence of the counter');
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'checking the persistence of the counter');
if($elem) {
    is $elem->as_trimmed_text, 2, 'checking the persistence of the counter';
}

$mech->get_ok('/special/counter.subtract', 'checking the subtract controller');
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'checking that the counter has been decremented');
if($elem) {
    is $elem->as_trimmed_text, 1, 'checking the counter update';
}

$mech->get_ok('/special/counter.subtract', 'checking the subtract controller again');
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'checking that the counter has been decremented');
if($elem) {
    is $elem->as_trimmed_text, 0, 'checking the counter update again';
}

$mech->get_ok('/special/counter', 'checking the persistence of the counter again');
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'checking the persistence of the counter');
if($elem) {
    is $elem->as_trimmed_text, 0, 'checking the persistence of the counter again';
}

$mech->get_ok('/special/counter.view', 'checking that the view controller works');
ok(($elem) = $mech->look_down(
    _tag => 'p',
    id => 'count'
), 'checking the view controller');
if($elem) {
    is $elem->as_trimmed_text, 0, 'checking that the view controller works';
}
