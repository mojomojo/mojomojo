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
	return "http://example.com";
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
    my ($self,$path)=@_;
    $path=~s|^/||;
	if ($path =~ /Existing/) {
		my $page = Dummy->new;
		$page->{path} = $path;
		return [$page], undef;
	} else {
		return [], [{path => $path}];
	}
}

sub pref { return 1; }

package main;

use MojoMojo::Formatter::Wiki;
use Test::More;

plan tests => 14;

my ($content,$exist,$new);

$content = '[[ExistingWord]]';
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '<a class="existingWikiWord" href="http://example.com/ExistingWord">Existing Word</a> ');

$content = '[[Existing. WithDot]]';
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '<a class="existingWikiWord" href="http://example.com/Existing_WithDot">Existing. With Dot</a> ','Existing .WithDot');

$content = '[[New. WithDot]]';
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '<span class="newWikiWord">New. With Dot<a title="Not found. Click to create this page." href="http://example.com/New_WithDot.edit">?</a></span>','New.WithDot');


$content = '\[[WikiWord]]';

MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '[[WikiWord]]');

$content = '/[[wikiword]]';
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '/[[wikiword]]');

$content = "WikiWord";
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, 'WikiWord');

$content = "ExistingWord";
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, 'ExistingWord');

$content = qq{[[WikiWord]] <pre><code>Blah</code>\nHubbaBubba [[Wikwiord]]</pre> blah humbug [[ExistingWikiWord]]};
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, qq{<span class="newWikiWord">Wiki Word<a title="Not found. Click to create this page." href="http://example.com/WikiWord.edit">?</a></span> <pre lang=""><code>Blah</code>\nHubbaBubba [[Wikwiord]]</pre> blah humbug <a class="existingWikiWord" href="http://example.com/ExistingWikiWord">Existing Wiki Word</a> });


$content = 'There is one [[Existing Word]] in this text';
 ($exist, $new) = MojoMojo::Formatter::Wiki->find_links (\$content, Dummy->new);
is(@$exist, 1);
is(@$new, 0);

$content = 'There is one explicit [[Wiki Word]] in this text';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links (\$content, Dummy->new);
is(@$exist, 0);
is(@$new, 1);
$_[0]->{path} = '/';

$content = '[[Wiki Word]] <pre lang="">Blah HubbaBubba Wikwiord</pre> blah humbug [[Existing Wiki Word]]';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links (\$content, Dummy->new);
is(@$exist, 1);
is(@$new, 1);

