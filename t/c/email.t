use strict;
use warnings;
use Test::More tests => 14;
use lib 't/lib';
use MojoMojoTestSchema;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
}

use Email::Send::Test;
use Test::WWW::Mechanize::Catalyst 'MojoMojo';

my $mech = Test::WWW::Mechanize::Catalyst->new;

# Clear out emails even though there shouldn't be any yet.
Email::Send::Test->clear;
is( Email::Send::Test->emails, 0, 'no mails sent yet' );

$mech->get_ok('/.recover_pass');
$mech->submit_form_ok( { fields => { recover => 'admin', }, },
    'recover submit' );

is( Email::Send::Test->emails, 1, 'new password emailed' );

# NOTE: The email body content checks are looking for English
my ($mail) = Email::Send::Test->emails;
like( $mail->header('To'), qr/^admin/,        'right recipient' );
like( $mail->body,         qr/new password/i, 'email contains a new password' );

# After requesting password recovery, restore the original password
ok my $schema = MojoMojoTestSchema->get_schema, 'get the schema in order to...';
ok $schema->resultset('Person')->find({login => 'admin'})->update({pass=>"admin"}), "...reset admin's password to 'admin'";


# Clear email trap before next test per doc recommendation.
Email::Send::Test->clear;
is( Email::Send::Test->emails, 0, 'email trap reset' );

$mech->get_ok('/.register');

# Create a random login and email:
# This test has very small chance of failing if it's been run
# before and the random digit is repeated.
my $login = 'mojam';
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

        },
    },
    'Register submit'
);

# NOTE: This test will fail if the user already exists in t/var/mojomojo.db
# Run: prove --lib /lib t/01app.t to start with fresh database and then run this test.
is( Email::Send::Test->emails, 1, 'regisration validation email sent' );
($mail) = Email::Send::Test->emails;
like( $mail->header('To'), qr/^mojam/,        'right recipient' );
like( $mail->body,         qr/validate your email address/i, 'email contains validate email address' );

