use strict;
use warnings;
use Test::More tests => 6;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
}

use Email::Send::Test;
use Test::WWW::Mechanize::Catalyst 'MojoMojo';

my $mech = Test::WWW::Mechanize::Catalyst->new;

Email::Send::Test->clear;

$mech->get_ok('/.recover_pass');
is(Email::Send::Test->emails, 0, 'no mails sent yet');

$mech->submit_form_ok({
    fields => {
        recover => 'admin',
    },
}, 'recover submit');

is(Email::Send::Test->emails, 1, 'new password emailed');

my ($mail) = Email::Send::Test->emails;
like($mail->header('To'), qr/^admin/, 'right recipient');
like($mail->body, qr/new password/i, 'email contains a new password');
