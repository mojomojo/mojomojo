#!/usr/bin/perl -w
use Test::More tests => 8;
use HTTP::Request::Common;
use Test::Differences;

my $original_formatter;  # used to store whatever formatter is set up in mojomojo.db
my $c;  # the Catalyst object of this live server

BEGIN {
    $ENV{CATALYST_CONFIG} = 't/var/mojomojo.yml';
    $ENV{CATALYST_DEBUG} = 0;
    use_ok('MojoMojo::Formatter::Textile') and note('Comprehensive/chained test of formatters, with the main formatter set to Textile');
    use_ok(Catalyst::Test, 'MojoMojo');
    
    (undef, $c) = ctx_request('/');
    ok($original_formatter = $c->pref(main_formatter), 'save original formatter');
};

END {
    ok($c->pref(main_formatter => original_formatter), 'restore original formatter');
}

ok($c->pref(main_formatter => 'MojoMojo::Formatter::Textile'), 'set preferred formatter to Markdown');

my $content = '';
my $body = get(POST '/.jsrpc/render', [content => $content]);
is($body, 'Please type something', 'empty body');

$content = <<TEXTILE;
h1. Welcome to MojoMojo!

This is your front page. To start administrating your wiki, please log in with
username admin/password admin. At that point you will be able to set up your
configuration. If you want to play around a little with the wiki, just create
a [[New Page]] or edit this one through the edit link at the bottom.

h2. Need some assistance?

Check out our [[Help]] section.
TEXTILE
$body = get(POST '/.jsrpc/render', [content => $content]);
eq_or_diff($body, <<HTML, 'headings');
<h1>Welcome to MojoMojo!</h1>

<p>This is your front page. To start administrating your wiki, please log in with<br />
username admin/password admin. At that point you will be able to set up your<br />
configuration. If you want to play around a little with the wiki, just create<br />
a <span class="newWikiWord">New Page<a title="Not found. Click to create this page." href="/New_Page.edit">?</a></span> or edit this one through the edit link at the bottom.</p>

<h2>Need some assistance?</h2>

<p>Check out our <a class="existingWikiWord" href="/help">Help</a> section.</p>
HTML

$content = <<TEXTILE;
Here's some code:

<pre lang="Perl">
if (1 > 2) {
  print "test";
}
</pre>

Here too:

<pre>
if (1 > 2) {
  print "test";
}
</pre>
TEXTILE
$body = get(POST '/.jsrpc/render', [content => $content]);
eq_or_diff($body, <<HTML, 'HTML entities must be preserved in code sections');
<p>Here&#8217;s some code:</p>



<pre>
<b>if</b>&nbsp;(<span class="kateFloat">1</span>&nbsp;>&nbsp;<span class="kateFloat">2</span>)&nbsp;{
&nbsp;&nbsp;<span class="kateFunction">print</span>&nbsp;<span class="kateOperator">"</span><span class="kateString">test</span><span class="kateOperator">"</span>;
}
</pre>



<p>Here too:</p>



<pre>
if (1 > 2) {
  print "test";
}
</pre>
HTML
