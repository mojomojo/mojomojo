#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Scrub;
use Test::More tests => 6;
use Test::Differences;
use utf8;

my ( $content, $got, $expected, $test );

#-------------------------------------------------------------------------------
TODO: {
    local $TODO = "the HTML scrubber should not mess with Unicode characters in links";
    $test = "leave Unicode characters alone in links; they're perfectly valid XHTML 1.0 Strict per W3C";
    my $unicode_string = 'התפוצצות אוכלוסין';
    $content = << "HTML";
Hebrew link title alone: $unicode_string

<a href="http://he.wikipedia.org/wiki/$unicode_string">Some Hebrew link</a>
HTML
    MojoMojo::Formatter::Scrub->format_content( \$content );
    eq_or_diff( $content, <<"HTML", $test );
Hebrew link title alone: $unicode_string

<a href="http://he.wikipedia.org/wiki/$unicode_string">Some Hebrew link</a>
HTML
}


#-------------------------------------------------------------------------------
$test = 'complete set of html table tags';
$content = <<'HTML_TABLE';
<table summary="Vegetable Price List">
<caption>Vegetable Price List</caption>
<colgroup><col /><col align="right" /></colgroup>
<thead>
    <tr>
      <th>Vegetable</th>
      <th>Cost per kilo</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Lettuce</td>
      <td>$1</td>
    </tr>
    <tr>
      <td>Silver carrots</td>
      <td>$10.50</td>
    </tr>
    <tr>
      <td>Golden turnips</td>
      <td>$108.00</td>
    </tr>
</tbody>
</table>
HTML_TABLE

# We expect Scrub to leave this table as is.
#$expected = $content;
MojoMojo::Formatter::Scrub->format_content( \$content );
is( $content, <<'HTML_TABLE', $test );
<table summary="Vegetable Price List">
<caption>Vegetable Price List</caption>
<colgroup><col /><col align="right" /></colgroup>
<thead>
    <tr>
      <th>Vegetable</th>
      <th>Cost per kilo</th>
    </tr>
</thead>
<tbody>
    <tr>
      <td>Lettuce</td>
      <td>$1</td>
    </tr>
    <tr>
      <td>Silver carrots</td>
      <td>$10.50</td>
    </tr>
    <tr>
      <td>Golden turnips</td>
      <td>$108.00</td>
    </tr>
</tbody>
</table>
HTML_TABLE

#-------------------------------------------------------------------------------
$test = 'iframe not allowed';
$content = <<'HTML';
<iframe src="http://dandascalescu.com/bugs/mojomojo/scriptlet.html" />
HTML
MojoMojo::Formatter::Scrub->format_content( \$content );
eq_or_diff( $content, <<'HTML', $test );

HTML

#-------------------------------------------------------------------------------
$test = 'script not allowed';
$content = <<'HTML';
<SCRIPT SRC=http://ha.ckers.org/xss.js></SCRIPT>
HTML
MojoMojo::Formatter::Scrub->format_content( \$content );
eq_or_diff( $content, <<'HTML', $test );

HTML

##-------------------------------------------------------------------------------
#$test = 'img src javascript not allowed';
#$content = <<'HTML';
#<IMG SRC="javascript:alert('XSS');">
#HTML
#my $impact = MojoMojo::Formatter::Scrub->format_content( \$content );
#eq_or_diff( $content, <<'HTML', $test );
#
#HTML

#-------------------------------------------------------------------------------
$test = 'http external images not allowed';
$content = <<'HTML';
<img src="http://youporn.com/hot.jpg" />
HTML
MojoMojo::Formatter::Scrub->format_content( \$content );
eq_or_diff( $content, <<'HTML', $test );
<img>
HTML

#-------------------------------------------------------------------------------
$test = 'https external images not allowed';
$content = <<'HTML';
<img src="https://youporn.com/hot.jpg" />
HTML
MojoMojo::Formatter::Scrub->format_content( \$content );
eq_or_diff( $content, <<'HTML', $test );
<img>
HTML



