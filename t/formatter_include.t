#!/usr/bin/perl -w
package Dummy;
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

sub stash {
	my $self = shift;
	return { page => $self,
		 page_path => 'http://example.com/',
	};
}

sub path {
	my $self = shift;
	$path = $self->{path};
	return $path;
}

sub model {
	return $_[0];
}

sub result_source {
	return $_[0];
}

sub resultset {
	return $_[0];
}

sub path_pages {
	if ($_[1] =~ /Existing/) {
		my $page = Dummy->new;
		$page->{path} = '/ExistingWord';
		return [$page], undef;
	} else {
		return [], [{path => '/WikiWord'}];
	}
}

sub cache {
    my ($self,$c)=@_;
    return undef;
}

package main;

use MojoMojo::Formatter::Include;
use Test::More;

if ($ENV{TEST_LIVE}) {
    plan tests => 2;
}
else {
    plan skip_all => "set TEST_LIVE to run tests that requires a live internet connection";
}

my ($content,$exist,$new);

$content = "{{http://github.com/marcusramberg/mojomojo/raw/85605d55158b1e6380457d4ddc31e34b7a77875a/Changes\n";
MojoMojo::Formatter::Include->format_content(\$content, Dummy->new, undef);
warn("Content is $content");
like($content, qr{0\.999001\s+2007\-08\-29\s16\:29\:00});

$content = "\n=http://example.com/test/\n";
MojoMojo::Formatter::Include->format_content(\$content, Dummy->new, undef);
like($content, qr{part of own site, cannot include});
