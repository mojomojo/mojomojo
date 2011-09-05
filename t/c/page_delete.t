#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib 't/lib';
use MojoMojoTestSchema;

BEGIN
{
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
}

BEGIN
{
    eval "use Test::WWW::Mechanize::Catalyst 'MojoMojo'";
    plan skip_all => 'need Test::WWW::Mechanize::Catalyst' if $@;

    eval "use WWW::Mechanize::TreeBuilder";
    plan skip_all => 'need WWW::Mechanize::TreeBuilder' if $@;

    plan tests => 31;
}
use_ok('MojoMojo::Controller::Page');

my $mech = Test::WWW::Mechanize::Catalyst->new;
WWW::Mechanize::TreeBuilder->meta->apply($mech);

my ($elem);
my $random = rand
  ; # unique string to be inserted in created pages so that repeated runs of this test don't accidentally pass thanks to previously submitted page contents

$mech->post(
    '/.login',
    {
        login => 'admin',
        pass  => 'admin'
    }
);
ok $mech->success, 'logging in as admin';

ok(
    ($elem) = $mech->look_down(
        _tag   => 'a',
        'href' => qr'/admin$'
    ),
    'admin link'
);

# Get the name of the admin user. Then test against it.
ok my $schema = MojoMojoTestSchema->get_schema,
  'get the schema to get the name of admin user.';
ok my $admin_user = $schema->resultset('Person')->find({ login => 'admin' }),
  'get admin user Person row object';
if ($elem)
{
    is $elem->as_trimmed_text, $admin_user->name, 'logged in as admin';
}

$mech->get_ok('/.delete', 'can request delete page');

ok(($elem) = $mech->look_down(_tag => 'h3',), 'delete header');
if ($elem)
{
    is $elem->as_trimmed_text, 'Sorry', 'root page cannot be deleted';
}

#----------------------------------------------------------------------------
# Create a page
$mech->get_ok('/to_delete.edit', 'can edit to_delete page');
ok $mech->form_with_fields('body'), 'find the edit form';
ok defined $mech->field(
    body => <<PAGE_CONTENT,
# This is a test page

It was submitted via {{cpan Test::WWW::Mechanize::Catalyst}} with a random string of '$random'.

It also links to [[/|the root page]] and [[/help]].
PAGE_CONTENT
  ),
  'set the "body" value';

# we should click 'Save and View' but that causes WWW::Mechanize to die with `Can't call method "header" on an undefined value at /usr/local/share/perl/5.8.8/WWW/Mechanize.pm line 2381`
ok $mech->click_button(value => 'Save'), 'click the "Save" button';

$mech->content_contains( <<RENDERED_CONTENT, 'content rendered correctly');
<h1>This is a test page</h1>

<p>It was submitted via <a href="http://search.cpan.org/perldoc?Test::WWW::Mechanize::Catalyst" class="external">Test::WWW::Mechanize::Catalyst</a> with a random string of '$random'.</p>

<p>It also links to <a class="existingWikiWord" href="/">the root page</a> and <a class="existingWikiWord" href="/help">help</a>.</p>
RENDERED_CONTENT

#----------------------------------------------------------------------------
# Delete a page
$mech->get_ok('/to_delete.delete', 'can request delete request');

ok(($elem) = $mech->look_down(_tag => 'h3',), 'delete header');
if ($elem)
{
    is $elem->as_trimmed_text, 'Are you sure you want to delete to_delete?',
      'page can be deleted';
}

$mech->form_number(2);
ok $mech->click_button(value => 'Yes'), 'click the "Yes" button';

#----------------------------------------------------------------------------
# Search for deleted page
$mech->post( '/.search',
    {
        form_number => 1,
        fields      => { q => $random }
    },
    "searching for random bit: $random"
);

is $mech->look_down(_tag => 'h3')->as_trimmed_text,
  'No results found', 'page is gone from search index';

#----------------------------------------------------------------------------
# Test we can't delete a page as non-admin user

# Make sure Logged out
$mech->get_ok('/.logout');

# Post registration
# Create a random login and email:
# This test has very small chance of failing if it's been run
# before and the random digit is repeated.
my $login        = 'avatar';
my $random_digit = int(rand(1000000));
$login .= $random_digit;
my $email_domain = '@bogusness.org';
my $email        = $login . $email_domain;
my $pass         = 'jake';

# Create non-admin user for testing page delete
my @people = $schema->populate(
    'Person',
    [
        [
            qw/ active views photo login name email pass timezone born gender occupation industry interests movies music /
        ],
        [
            1, 0, 0, $login, 'Avatar', $email, $pass, '', undef, '', '', '', '',
            '', ''
        ],
    ]
);

# Check user exists and is active
my $non_admin_user = $schema->resultset('Person')->find(
    {
        login => $login,
        key   => 'login'
    }
);
is($non_admin_user->active, 1, 'Avatar user active');

# non_admin_user have role User (permissions is based on user role)
ok(
    $schema->resultset('RoleMember')->create(
        {
            role   => 2,
            person => $non_admin_user->id,
            admin  => 0,
        }
    ),
    "non_admin_user have role User"
);

# Login as non-admin user
$mech->post(
    '/.login',
    {
        login => $login,
        pass  => $pass,
    }
);
ok $mech->success, 'logging in as ' . $login;
$mech->content_contains('Avatar', 'Avatar name found');

# Create a page which we'll attempt to delete
$mech->get_ok('/attempt_to_delete.edit', 'can edit attempt_to_delete page');
ok $mech->form_with_fields('body'), 'find the edit form';
ok defined $mech->field(
    body => <<PAGE_CONTENT,
# This is a test page
PAGE_CONTENT
  ),
  'set the "body" value';

# we should click 'Save and View' but that causes WWW::Mechanize to die with `Can't call method "header" on an undefined value at /usr/local/share/perl/5.8.8/WWW/Mechanize.pm line 2381`
ok $mech->click_button(value => 'Save'), 'click the "Save" button';
$mech->content_contains( <<RENDERED_CONTENT, 'content rendered correctly');
<h1>This is a test page</h1>
RENDERED_CONTENT

# Attempt to delete a page
$mech->get_ok('/attempt_to_delete.delete', 'make request to delete a page');
my $content = $mech->content;
like($content, qr/Restricted area. Admin access required/, 'Delete a page restricted to admins');
