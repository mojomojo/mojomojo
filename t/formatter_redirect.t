#!/usr/bin/perl -w
package Dummy;
sub new {
    my $class = shift;
    bless {}, $class;
}

sub req {
    return $_[0];
}

sub res {
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

sub ajax {}

sub action {
    return $_[0];
}

sub name { 'view' }


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


sub redirect {
    my ($self,$url)=@_;
    $self->{url}=$url if $url;
    return $self->{url};
}

sub uri_for {
    my ($self,$url)=@_;
    return $url;
}

package main;

use MojoMojo::Formatter::Redirect;
use Test::More;

    plan tests => 2;


my ($content,$exist,$new,$fake_c);

$content = "=redirect /foo";
$fake_c=Dummy->new;
MojoMojo::Formatter::Redirect->format_content(\$content, $fake_c, undef);
is($fake_c->redirect, '/foo' ,"Redirect is set");
is($content,"=redirect /foo","Content is unchanged");
