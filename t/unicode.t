#!/usr/bin/env perl
# Unicode tests: Unicode text in page content, wiki links, tags etc.
use strict;
use warnings;
use Test::More tests => 9;
use HTTP::Request::Common;
use Test::Differences;
use utf8;

my $original_formatter;    # current formatter set up in mojomojo.db
my $c;                     # the Catalyst object of this live server
my $test;                  # test description
my $content;               # source markup
my $body;                  # # the MojoMojo page body as fetched by get()
my $mech = Test::WWW::Mechanize::Catalyst->new;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok 'MojoMojo::Formatter::Markdown';
    
    use_ok 'Catalyst::Test', 'MojoMojo';
    # We should only use Catalyst::Test here, but we can't until it fixes this Unicode-related bug:
    # http://dev.catalyst.perl.org/wiki/bugs/Catalyst_Test_get_does_not_encode_the_content
    use_ok 'Test::WWW::Mechanize::Catalyst', 'MojoMojo';
}

END {
    ok( $c->pref( main_formatter => $original_formatter ),
        'restore original formatter' );
}

# Prepare the test environment by setting the primary formatter to Markdown
( undef, $c ) = ctx_request('/');
ok( $original_formatter = $c->pref('main_formatter'),
    'save original formatter' );

ok( $c->pref( main_formatter => 'MojoMojo::Formatter::Markdown' ),
    'set preferred formatter to Markdown' );

#-------------------------------------------------------------------------------
$test = "basic Unicode: page content";
$content = 'ებრაული ენა (עברית, ივრით), განეკუთვნება სემიტურ ენათა ქანაანურ ჯგუფს.';
$mech->post_ok('/.jsrpc/render', { content => $content });
$mech->content_is('<p>ებრაული ენა (עברית, ივრით), განეკუთვნება სემიტურ ენათა ქანაანურ ჯგუფს.</p>' . "\n", $test);


#-------------------------------------------------------------------------------
$test = 'Unicode wikilinks';
my $unicode_string = 'განეკუთვნება';
$content = "[[$unicode_string]]";
$mech->post('/.jsrpc/render', { content => $content });
$mech->content_is(<<"HTML", $test);
<p><span class="newWikiWord"><a title="Not found. Click to create this page." href="/$unicode_string.edit">$unicode_string?</a></span></p>
HTML
