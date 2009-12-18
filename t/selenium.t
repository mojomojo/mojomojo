#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

# This test requires that a Selenium server be running.  A Selenium server
# is included in Alien::SeleniumRC which is a dependency of
# Test::WWW::Selenium::Catalyst so having it installed should be
# sufficient to run this test.
#
# The selenium server is a java application that can also be started like:
#     java -jar selenium-server.jar
# See http://seleniumhq.org/ for the download of Selenium Remote Control (RC)
# which includes a selenium server.



BEGIN {
    eval {require Test::WWW::Selenium::Catalyst};
    plan skip_all => 'Selenium tests need Test::WWW::Selenium::Catalyst'
        if $@;
    plan tests => 22;
    $ENV{MOJOMOJO_CONFIG} = 't/app/mojomojo.yml';
}


Test::WWW::Selenium::Catalyst->import('MojoMojo');
my $sel = Test::WWW::Selenium::Catalyst->start;

$sel->open_ok("/");
$sel->is_text_present_ok("Log in");
$sel->open_ok("admin.profile");
$sel->is_text_present_ok("Log in");
$sel->open_ok(".recent");
$sel->is_text_present_ok("Log in");
$sel->open_ok(".list");
$sel->is_text_present_ok("Log in");
$sel->click_ok("link=Log in");
$sel->wait_for_page_to_load_ok( "15000");
$sel->type_ok( "loginField", "admin" );
$sel->type_ok( "pass",       "admin" );
$sel->click_ok("//input[\@value='Login']");
$sel->wait_for_page_to_load_ok("15000");
$sel->is_text_present_ok("admin");

# Check that .recent was not cached.
$sel->open_ok(".recent");
$sel->is_text_present_ok("Log out");

# Check that profile was no cached.
$sel->open_ok("admin.profile");
$sel->is_text_present_ok("Log out");
$sel->open_ok(".list");
$sel->is_text_present_ok("Log out");
$sel->click_ok("link=Log out");
