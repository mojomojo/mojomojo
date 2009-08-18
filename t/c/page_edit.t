#!/usr/bin/perl -w
use Test::More ;
BEGIN{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
};

BEGIN {
    eval "use Test::WWW::Mechanize::Catalyst 'MojoMojo'";
    plan skip_all => 'need Test::WWW::Mechanize::Catalyst' if $@;

    eval "use WWW::Mechanize::TreeBuilder";
    plan skip_all => 'need WWW::Mechanize::TreeBuilder' if $@;

    plan tests => 13;
}

use_ok('MojoMojo::Controller::Page');

my $mech = Test::WWW::Mechanize::Catalyst->new;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

my ($elem);
my $random = rand;  # unique string to be inserted in created pages so that repeated runs of this test don't accidentally pass thanks to previously submitted page contents

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


#----------------------------------------------------------------------------
# Create a page
$mech->get_ok('/test.edit', 'edit a test page');
ok $mech->form_with_fields('body'), 'find the edit form';
ok defined $mech->field(body => <<PAGE_CONTENT,
# This is a test page

It was submitted via {{cpan Test::WWW::Mechanize::Catalyst}} with a random string of '$random'.

It also links to [[/|the root page]] and [[/help]].
PAGE_CONTENT
), 'set the "body" value';
# we should click 'Save and View' but that causes WWW::Mechanize to die with `Can't call method "header" on an undefined value at /usr/local/share/perl/5.8.8/WWW/Mechanize.pm line 2381`
ok $mech->click_button(value => 'Save'), 'click the "Save" button';

$mech->content_contains(<<RENDERED_CONTENT, 'content rendered correctly');
<h1>This is a test page</h1>

<p>It was submitted via <a href="http://search.cpan.org/perldoc?Test::WWW::Mechanize::Catalyst" class="external">Test::WWW::Mechanize::Catalyst</a> with a random string of '$random'.</p>

<p>It also links to <a class="existingWikiWord" href="/">the root page</a> and <a class="existingWikiWord" href="/help">help</a>.</p>
RENDERED_CONTENT
