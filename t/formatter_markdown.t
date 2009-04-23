#!/usr/bin/perl -w
use strict;
use MojoMojo::Formatter::Markdown;
use Test::More;

my ( $response, $c );    # the Catalyst object of this live server

BEGIN {
    plan skip_all => 'Requirements not installed for Markdown Formatter'
      unless MojoMojo::Formatter::Markdown->module_loaded;
    plan tests => 3;
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG}  = 0;
    use_ok( 'Catalyst::Test', 'MojoMojo' );
    ( $response, $c ) = ctx_request('/');
}

$c->pref( 'main_formatter', 'MojoMojo::Formatter::Markdown' );

my ( $content, $got, $expect, $test );

TODO: {
    local $TODO = 'Markdown does not like <div> around its image tags';
    $test = "Keep divs, spans and their styling attributes\n";

    $content = <<MARKDOWN;
Can divs be used to add captions to images

<div class="photo">
![Beer](/images/frosty_mug.jpg "Cold One")
<span style="color: green">This is an image caption</span>
</div>

Divs, spans, and their styling attributes should be kept.
MARKDOWN

    $got = MojoMojo::Formatter::Markdown->format_content( \$content, $c );
    $expect = <<HTML;
<p>Can divs be used to add captions to images</p>

<div class="photo">
![Beer](/images/frosty_mug.jpg "Cold One")
<span style="color: green">This is an image caption</span>
</div>

<p>Divs, spans, and their styling attributes should be kept.</p>
HTML

    is( $got, $expect, $test );
}

TODO: {
    local $TODO = 'Markdown does not like lines starting with # in a <pre>.';
    $test = "No Markdown parsing in <pre> sections.\n";

    $content = <<MARKDOWN;
<pre lang="Perl">
# A comment, not a heading
</pre>
MARKDOWN

    $got = MojoMojo::Formatter::Markdown->format_content( \$content, $c );
    $expect = <<HTML;
<pre lang="Perl">
<h1>A comment, not a heading</h1>

</pre>
HTML
    is( $got, $expect, $test );

}
