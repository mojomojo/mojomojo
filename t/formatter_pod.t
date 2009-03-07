#!/usr/bin/perl -w

package Dummy;

use URI;

sub new {
	my $class = shift;
	bless {}, $class;
}

sub req {
	return $_[0];
}

sub base {
	$_[0]->{path} ||= '/';
	return URI->new("http://example.com/");
}

package main;

use Test::More tests => 2;

use MojoMojo::Formatter::Pod;

my $content;

my $ib = '{{pod}}';
my $ie = '{{end}}';
$content = "\n$ib\n\n\n=head1 FOO\n\nTest message\n\n=cut\n\n$ie\n";
MojoMojo::Formatter::Pod->format_content(\$content,Dummy->new);
like($content, qr/\<h1\>/, "h1");
like($content, qr/FOO/, "foo");


