#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib 't/lib';
use MojoMojoTestSchema;

BEGIN {
    $ENV{EMAIL_SENDER_TRANSPORT} = 'Test';
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
}

use Email::Sender::Simple;
use Test::WWW::Mechanize::Catalyst 'MojoMojo';

my $mech = Test::WWW::Mechanize::Catalyst->new;
my $sender = Email::Sender::Simple->default_transport;
# Clear out emails even though there shouldn't be any yet.

is( scalar( @{$sender->deliveries} ), 0, 'no mails sent yet' );

$mech->get_ok('/.recover_pass');
$mech->submit_form_ok( { fields => { recover => 'admin', }, },
    'recover submit' );

is( scalar( @{$sender->deliveries} ), 1, 'new password emailed' );

# NOTE: The email body content checks are looking for English
my ($mail) = $sender->deliveries->[0];
like( $mail->{email}->get_header( 'to' ), qr/^admin/, 'right recipient' );
like( $mail->{email}->get_body,           qr/new password/i, 'email contains a new password' );

# After requesting password recovery, restore the original password
ok my $schema = MojoMojoTestSchema->get_schema, 'get the schema in order to...';
ok $schema->resultset('Person')->find({login => 'admin'})->update({pass=>"admin"}), "...reset admin's password to 'admin'";


# Clear email trap before next test per doc recommendation.
$sender->clear_deliveries;
is( scalar( @{$sender->deliveries} ), 0, 'email trap reset' );

$mech->get_ok('/.register');

# Create a random login and email:
# This test has very small chance of failing if it's been run
# before and the random digit is repeated.
my $login = 'mojam';
my $user=$schema->resultset('Person')->find({login =>'mojam'});
$user->delete if $user;
my $random_digit = int(rand(1000000));
$login .= $random_digit;
my $email_domain = '@bogusness.org';
my $email = $login . $email_domain;

$mech->submit_form_ok(
    {
        fields => {
            login            => $login,
            pass             => 'secure',
            confirm_password => 'secure',
            email            => $email,
            name             => 'Writer',
            submit           => 'Register',
            antispam         => 'mojomojo',

        },
    },
    'Register submit'
);

# NOTE: This test will fail if the user already exists in t/var/mojomojo.db
# Run: prove --lib /lib t/01app.t to start with fresh database and then run this test.
is( scalar( @{$sender->deliveries} ), 1, 'registerration validation email sent' );
($mail) = $sender->deliveries->[0];
like( $mail->{email}->get_header('to'), qr/^mojam/,        'right recipient' );
like( $mail->{email}->get_body,         qr/validate your email address/i, 'email contains validate email address' );

done_testing();
