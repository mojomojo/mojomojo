#!/usr/bin/perl -w
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
$sel->wait_for_page_to_load_ok("30000", 'wait');
$sel->type_ok("loginField", "admin");
$sel->type_ok("pass", "admin");
$sel->click_ok("//input[\@value='log in']");
$sel->wait_for_page_to_load_ok("30000");
$sel->is_text_present_ok("admin");
$sel->is_text_present_ok("Log out");
$sel->click_ok("link=Log out");
