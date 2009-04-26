#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Scrub;
use Test::More tests => 1;

my ( $content, $got, $expected, $test );

#----------------------------------------------------------------------------
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
$expected = $content;
MojoMojo::Formatter::Scrub->format_content( \$content );
is( $content, $expected, $test );

