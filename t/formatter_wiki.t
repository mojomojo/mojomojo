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
	if ($_[1] =~ /Existing/) {
		my $page = Dummy->new;
		$page->{path} = '/ExistingWord';
		return [$page], undef;
	} else {
		return [], [{path => '/WikiWord'}];
	}
}

sub pref { return 1; }

package main;

use MojoMojo::Formatter::Wiki;
use Test::More;

plan tests => 12;

my ($content,$exist,$new);

$content = '[[ExistingWord]]';
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '<a class="existingWikiWord" href="http://example.com/ExistingWord">Existing Word</a> ');

$content = '\WikiWord';
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, 'WikiWord');

$content = '/[[wikiword]]';
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '/[[wikiword]]');

#$content = 'text+%3D+more';
#MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
#is($content, '<p>text = more</p>');

$content = "WikiWord";
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '<span class="newWikiWord">Wiki Word<a title="Not found. Click to create this page." href="http://example.com/WikiWord.edit">?</a></span>');

$content = "ExistingWord";
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, '<a class="existingWikiWord" href="http://example.com/ExistingWord">Existing Word</a> ');

$content = qq{WikiWord <pre><code>Blah</code>\nHubbaBubba Wikwiord</pre> blah humbug ExistingWikiWord};
MojoMojo::Formatter::Wiki->format_content(\$content, Dummy->new, undef);
is($content, qq{<span class="newWikiWord">Wiki Word<a title="Not found. Click to create this page." href="http://example.com/WikiWord.edit">?</a></span> <pre><code>Blah</code>\nHubbaBubba Wikwiord</pre> blah humbug <a class="existingWikiWord" href="http://example.com/ExistingWord">Existing Wiki Word</a> });


$content = 'ExistingWord';
 ($exist, $new) = MojoMojo::Formatter::Wiki->find_links (\$content, Dummy->new);
is(@$exist, 1);
is(@$new, 0);

$content = 'WikiWord';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links (\$content, Dummy->new);
is(@$exist, 0);
is(@$new, 1);
$_[0]->{path} = '/';

$content = 'WikiWord <pre>Blah HubbaBubba Wikwiord</pre> blah humbug ExistingWikiWord';
($exist, $new) = MojoMojo::Formatter::Wiki->find_links (\$content, Dummy->new);
is(@$exist, 1);
is(@$new, 1);

