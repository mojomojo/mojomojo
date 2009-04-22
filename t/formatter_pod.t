#!/usr/bin/perl -w
use MojoMojo::Formatter::Pod;
use Test::More tests => 2;
use lib 't/lib';
use DummyCatalystObject;

my $content;

my $ib = '{{pod}}';
my $ie = '{{end}}';
$content = "\n$ib\n\n\n=head1 FOO\n\nTest message\n\n=cut\n\n$ie\n";
MojoMojo::Formatter::Pod->format_content(\$content, DummyCatalystObject->new);
like($content, qr/\<h1\>/, "h1");
like($content, qr/FOO/, "foo");
