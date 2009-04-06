#!/usr/bin/perl -w
use Test::More tests => 2;
use MojoMojo::Formatter::Redirect;
use lib 't/lib';
use DummyCatalystObject;


my ($content,$exist,$new,$fake_c);
$fake_c = DummyCatalystObject->new;

$content = "=redirect /foo";
MojoMojo::Formatter::Redirect->format_content(\$content, $fake_c, undef);
is($fake_c->redirect, '/foo' ,"Redirect is set");
is($content,"=redirect /foo","Content is unchanged");
