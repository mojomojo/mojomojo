#!/usr/bin/perl -w
use MojoMojo::Formatter::Pod;
use Test::More tests => 2;
use lib 't/lib';
use DummyCatalystObject;

my $content;

my $ib = '{{pod}}';
my $ie = '{{end}}';
$content = <<POD;
$ib

=head1 FOO

Test message

=cut

$ie
POD
MojoMojo::Formatter::Pod->format_content(\$content, DummyCatalystObject->new);
like($content, qr'<h1><a.*FOO.*/h1>'s, "there is an h1 FOO");
like($content, qr'<p>Test message</p>', "there is a Test message");

