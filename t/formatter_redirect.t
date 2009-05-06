#!/usr/bin/perl -w
use Test::More tests => 4;
use MojoMojo::Formatter::Redirect;
use lib 't/lib';
use FakeCatalystObject;


my ($content, $exist, $new);
my $fake_c = FakeCatalystObject->new;

$content = "{{redirect /foo}}";
MojoMojo::Formatter::Redirect->format_content(\$content, $fake_c, undef);
is($fake_c->redirect, '/foo' ,"Redirect is set");
is($content,"{{redirect /foo}}","Content is unchanged");

$fake_c = FakeCatalystObject->new;
$content = "{{redirect /foo-bar-baz}}";
MojoMojo::Formatter::Redirect->format_content(\$content, $fake_c, undef);
is($fake_c->redirect, '/foo-bar-baz', "URL charset test");
is($content,"{{redirect /foo-bar-baz}}", "Content is unchanged");
