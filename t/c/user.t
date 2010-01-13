#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 13;

BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok('Catalyst::Test', 'MojoMojo');
    use_ok('MojoMojo::Controller::User');
    use_ok('Test::WWW::Mechanize::Catalyst', 'MojoMojo');
};

my $mech = Test::WWW::Mechanize::Catalyst->new;

#----------------------------------------------------------------------------
$mech->get('/.login?login=admin&pass=admin');
ok !$mech->success, 'non-POST logins return 400 and the login form';
ok !$mech->find_link(
    text => 'admin',
    url_regex => qr'/admin$'
), 'must login via POST';


#----------------------------------------------------------------------------
$mech->get_ok('/.users', 'got user list');
ok $mech->find_link(
    text => $ENV{USER} || 'admin',  # that's how MojoMojo::Schema sets the admin user's name
    url => '/admin.profile'
), 'found admin in the user list';
ok $mech->find_link(
    text => 'Anonymous Coward',
    url => '/anonymouscoward.profile'
), 'found Anonymous Coward in the user list';


#----------------------------------------------------------------------------
$mech->get_ok('/.login', 'got login form');
$mech->submit_form(
    with_fields => {
        login => 'admin',
        pass => 'wrong',
    }
);

ok !$mech->success, 'failing to login with wrong password';
ok !$mech->find_link(
    text => 'admin',
    url_regex => qr'/admin$'
), 'can log in as admin via URL';


#----------------------------------------------------------------------------
$mech->submit_form(
    with_fields => {
        login => 'admin',
        pass => 'admin',
    }
);
ok $mech->success, 'trying to login as admin via POST';
ok $mech->find_link(
    #text => 'admin',
    url_regex => qr'/admin$'
), 'can log in as admin via URL';
