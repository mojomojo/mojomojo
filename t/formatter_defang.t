#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 17;
use Test::Differences;
use HTTP::Request::Common;

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    use_ok 'MojoMojo::Formatter::Defang';
    use_ok 'Catalyst::Test', 'MojoMojo';
}

my ( $content, $got, $expected, $test );

$test = 'pre tag - no attribute';
$got = $content = <<'HTML';
<pre>
Hopen, Norway
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$got );
eq_or_diff( $got, $expected, $test );

$test = 'pre tag - lang HTML attribute';
$got = $content = <<'HTML';
<pre lang="HTML">
<strong>Zamość, Poland</strong>
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$got );
eq_or_diff( $got, $expected, $test );

$test = 'pre tag - lang Perl attribute';
$got = $content = <<'HTML';
<pre lang="Perl">
if ( $poble eq 'Sant Celoni') {
    say 'Visca Barça';
}
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$got );
eq_or_diff( $got, $expected, $test );

$test    = 'pre tag - no attribute and some text before a pre tag';
$got = $content = <<'HTML';
Tinc família a
<pre>
Hopen, Norway
</pre>
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$got );
eq_or_diff( $got, $expected, $test );

# This test will fail when allowing img and src at default Defang (return 2) setting.
$test     = 'formatter directly / remote image - should defang it';
$got = $content  = '<img src="http://far.away.com/image.jpg" />';
$expected = '<img defang_src="http://far.away.com/image.jpg" />';
MojoMojo::Formatter::Defang->format_content( \$got );
eq_or_diff( $got, $expected, $test );
$test     = 'full formatter chain / remote image - should defang it';
# tests are closer to reality if they call the JSRPC renderer, so that
# the entire formatter chain gets exercised, as in actual wiki usage
$got = get( POST '/.jsrpc/render', [ content => $content ] );
is( $got, "<p>$expected</p>\n", $test );


$test    = 'img src local tag';
$content = <<'HTML';
<img src="/.static/catalyst.png" alt="Powered by Catalyst" title="Powered by Catalyst" />
HTML
$expected = $content;
MojoMojo::Formatter::Defang->format_content( \$content );
eq_or_diff( $content, $expected, $test );

#-------------------------------------------------------------------------------
# Tests that make sure Defang doesn't corrupt links
TODO: {
    local $TODO = "MojoMojo::Formatter::Defang breaks links quite badly";
    $test = "don't mess up %26 in URLs";
    $content = "[company people hate](http://www.google.com/search?q=H%26R+block+sucks)";
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    $expected = '<p><a href="http://www.google.com/search?q=H%26R+block+sucks">company people hate</a></p>';
    is $got, "$expected\n", $test;
    
    $test = "don't mess up %40 in URLs";
    $content = "[dandv's Perl bugs](http://rt.perl.org/rt3/Public/Search/Simple.html?q=DanVDascalescu%40yahoo.com)";
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    $expected = '<p><a href="http://rt.perl.org/rt3/Public/Search/Simple.html?q=DanVDascalescu%40yahoo.com">dandv\'s Perl bugs</a></p>';
    is $got, "$expected\n", $test;
    
    $test = "don't mess up %3F in anchors";
    $content = '<a href="http://perldoc.perl.org/perlfaq1.html#Is-Perl-difficult-to-learn%3F">shallow (easy to learn)</a>';
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    $expected = "<p>$content</p>\n";
    is $got, $expected, $test;
    
    $test = "leave number sequences alone";
    $content = "[California Proposition 8](http://en.wikipedia.org/wiki/California_Proposition_8_%282008%29)";
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    $expected = '<p><a href="http://en.wikipedia.org/wiki/California_Proposition_8_%282008%29">California Proposition 8</a></p>';
    is $got, "$expected\n", $test;
    
    $test = "leave hex number sequences alone";
    $content = "[link](http://www.marketwatch.com/news/story/european-shares-plunge-global-rout/story.aspx?guid=%7BB5882B27-F163-4F02-B597-A19AB3B5E8A8%7D&dist=TNMostRead#comment804313)";
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    $expected = '<p><a href="http://www.marketwatch.com/news/story/european-shares-plunge-global-rout/story.aspx?guid=%7BB5882B27-F163-4F02-B597-A19AB3B5E8A8%7D&amp;dist=TNMostRead#comment804313">link</a></p>';
    is $got, "$expected\n", $test;
    
    $test = "leave short hex number sequences alone";
    $content = "[single %2BA](http://www.netsarang.com/forum/xshell/964/Does_Xshell_support_Ctrl%2BArrow_combinations)";
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    $expected = '<p><a href="http://www.netsarang.com/forum/xshell/964/Does_Xshell_support_Ctrl%2BArrow_combinations">single %2BA</a></p>';
    is $got, "$expected\n", $test;
    
    $test = "don't invent Unicode characters in links";
    $content = "[%20](http://www.tabspedia.com/108700.Iris%20-%20Baby%20Tab.html)";
    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    $expected = '<p><a href="http://www.tabspedia.com/108700.Iris%20-%20Baby%20Tab.html">%20</a></p>';
    is $got, "$expected\n", $test;
}

TODO: {
    local $TODO = "MojoMojo::Formatter::Defang is overzealous about footnote attributes";
    $test = 'Leave footnotes alone';
    
    $content = <<'MARKDOWN';
HTML::Formatter::Defang should not mess with footnotes[^bug].

[^bug]: And it doesn't.
MARKDOWN
    
    $expected = <<'HTML';
<p>HTML::Formatter::Defang should not mess with footnotes<a href="#fn:bug" id="fnref:bug" class="footnote">1</a>.</p>

<div class="footnotes">
<hr />
<ol>

<li id="fn:bug"><p>And it doesn't.<a href="#fnref:bug" class="reversefootnote">&#160;&#8617;</a></p></li>

</ol>
</div>
HTML

    $got = get( POST '/.jsrpc/render', [ content => $content ] );
    eq_or_diff $got, $expected, $test;
}
