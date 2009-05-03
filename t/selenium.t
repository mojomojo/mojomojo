#!/usr/bin/perl -w

# This test requires that the selenium server be running.
# The selenium server is a java application that can be started like:
#     java -jar selenium-server.jar
# See http://seleniumhq.org/ for the download of selenium server, remote control

BEGIN {
  $ENV{MOJOMOJO_CONFIG}='t/app/mojomojo.yml';
};
eval "use Test::WWW::Selenium::Catalyst 'MojoMojo'";
use Test::More;
plan skip_all => 'requires Test::WWW::Selenium::Catalyst' if $@;
plan tests => 11;

my $sel = Test::WWW::Selenium::Catalyst->start; 

$sel->open_ok("/");
$sel->is_text_present_ok("Log in");
$sel->click_ok("link=Log in");
$sel->wait_for_page_to_load_ok("15000", 'wait');
$sel->type_ok("loginField", "admin");
$sel->type_ok("pass", "admin");
$sel->click_ok("//input[\@value='Login']");
$sel->wait_for_page_to_load_ok("15000");
$sel->is_text_present_ok("admin");
$sel->is_text_present_ok("Log out");
$sel->click_ok("link=Log out");