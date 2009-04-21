#!/usr/bin/perl -w
package Dummy;
sub new {
    my $class = shift;
    bless {}, $class;
}

sub loc {
    return $_[1];
}

sub action {
    return $_[0];
}

sub reverse {
    return $reverse;
}

sub set_reverse {
   $reverse=$_[1];
}

sub cache {
    my ($self,$c)=@_;
    return undef;
}

sub session {
    my ($self,$c)=@_;
    return "";
}

sub pref {
    my ($self,$c)=@_;
    return "";
}



package main;

use MojoMojo::Formatter::YouTube;
use Test::More;

plan tests => 5;

my ($content,$exist,$new);

my $fake_c=Dummy->new;

$content = " youtube http://www.youtube.com/abc";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, " youtube http://www.youtube.com/abc\n","no youtube formatter line");

$fake_c->set_reverse('pageadmin/edit');
$content = "{{youtube http://www.youtube.com/v=abcABC0}}\n";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, qq(<div style='width: 425px;height: 344px; border: 1px black dotted;'>YouTube Video<br /><a href="http://www.youtube.com/v=abcABC0">http://www.youtube.com/v=abcABC0</a></div>\n));

$fake_c->set_reverse('jsrpc/render');
$content = "{{youtube http://www.youtube.com/v=abcABC0}} xx\n";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, qq(<div style='width: 425px;height: 344px; border: 1px black dotted;'>YouTube Video<br /><a href="http://www.youtube.com/v=abcABC0">http://www.youtube.com/v=abcABC0</a></div> xx\n));

$content = "{{youtube http://wwwwwwww.youtube.com/abc}}";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, "YouTube Video: http://wwwwwwww.youtube.com/abc is not a valid link to youtube video\n","no youtube link");

$fake_c->set_reverse('');

$content = "{{youtube http://www.youtube.com/watch?v=ABC_abc_09}}";
MojoMojo::Formatter::YouTube->format_content(\$content, $fake_c, undef);
#warn("Content is $content");
is($content, qq(<object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/ABC_abc_09&hl=en"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/ABC_abc_09&hl=en" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>\n));
