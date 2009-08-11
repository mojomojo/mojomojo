#!/usr/bin/perl -w
use Test::More tests => 22;
use Test::Differences;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
};
use_ok('Test::WWW::Mechanize::Catalyst', 'MojoMojo' );
use_ok('MojoMojo::Controller::Attachment');

my $mech = Test::WWW::Mechanize::Catalyst->new;
my $file_to_upload = $0;
my ($expected, @links, $url);

ok $mech->get('/.attachment/nonexistent'), 'getting a non-existent attachment';
ok !$mech->success, "invalid attachment";

$mech->post('/.login', {
    login => 'admin',
    pass => 'admin'
});
ok $mech->success, 'logging in as admin'
    or BAIL_OUT('must be able to login in order to upload attachments');
ok $mech->find_link(
    text => 'admin',
    url_regex => qr'/admin$'
), 'can log in as admin via URL'
    or BAIL_OUT('must be able to login in order to upload attachments');


#----------------------------------------------------------------------------
# Upload the same file twice

open my $file_in, '<', $file_to_upload
    or BAIL_OUT('cannot read the file to be uploaded: $file_to_upload');
(my $file_to_upload_RE = $file_to_upload) =~ s"(.*)[\\/](.*?)$"$2";
$file_to_upload_RE = quotemeta $file_to_upload_RE;
$expected = do {local $/; <$file_in>};

for (1..2) {
    $mech->get_ok('/.attachments?plain=1', 'got plain attachment upload form');
    ok $mech->form_with_fields('file'), 'found the upload file field';

    $mech->field(file => $file_to_upload);
    ok $mech->submit, "uploaded $file_to_upload";

    # get the *last* version of the uploaded file, in case we kept editing it then uploading it, without resetting the MojoMojo test database
    ok(@links = $mech->find_all_links(
        text_regex => qr/$file_to_upload_RE/
    ), 'the uploaded file (matching $file_to_upload_RE) is in the attachment list');

    $mech->get_ok($links[-1]->url, 'download the uploaded file');
    eq_or_diff $mech->content, $expected, "text file upload/download roundtrip";
}

($url = $mech->uri) =~ s/download$/delete/;
$mech->get_ok($url, 'delete attachment while logged in as admin');
$mech->get($url);
ok !$mech->success, 'cannot delete the same attachment again';


#----------------------------------------------------------------------------
# Now log out and make sure we can't delete attachments
# This has been a serious security flaw: http://mojomojo.ideascale.com/akira/dtd/22284-2416
$mech->get_ok('/.logout', 'log out');

($url = $links[-2]->url) =~ s/download$/delete/;
diag "URL: $url\n";
$mech->get($url);
ok !$mech->success, 'attachment deletion forbidden while NOT logged in';
