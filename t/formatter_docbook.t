#!/usr/bin/perl -w
use strict;
use Test::More;

BEGIN { 
    eval 'use MojoMojo::Formatter::DocBook';
    plan skip_all => 'MojoMojo::Formatter::DocBook not installed' if $@;
    plan skip_all => 'Requirements not installed for MojoMojo::Formatter::DocBook'
        unless MojoMojo::Formatter::DocBook->module_loaded;
    plan tests => 1;
};

{
    my $content = <<DBK;
<!DOCTYPE article PUBLIC "-//OASIS//DTD DocBook XML V4.4//EN"
"http://www.oasis-open.org/docbook/xml/4.4/docbookx.dtd">
<article lang="fr">
<programlisting lang="bash">
      #!/bin/sh -e

      PATH="/usr/bin:/bin";
      [ -x /bin/test ] || exit 0

      process_options() {
          [ -e /etc/network/options ] || return 0
      }
      </programlisting>
</article>
DBK
    my $html=MojoMojo::Formatter::DocBook->to_xhtml($content ) . "\n";
    ok($html, <<HTML);
<div class="article" xml:lang="fr"><div class="titlepage"><hr></hr></div><pre class="programlisting">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateComment"><i>#!/bin/sh&nbsp;-e</i></span><span class="kateComment"><i>
</i></span>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateOthers">PATH=</span><span class="kateString">"/usr/bin:/bin"</span>;
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateReserved"><b>&nbsp;[</b></span>&nbsp;-x&nbsp;/bin/test<span class="kateReserved"><b>&nbsp;]</b></span>&nbsp;<b>||</b>&nbsp;<span class="kateReserved"><b>exit</b></span>&nbsp;0

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateChar">process_options()</span>&nbsp;<b>{</b>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<span class="kateReserved"><b>&nbsp;[</b></span>&nbsp;-e&nbsp;/etc/network/options<span class="kateReserved"><b>&nbsp;]</b></span>&nbsp;<b>||</b>&nbsp;<span class="kateReserved"><b>return</b></span>&nbsp;0
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>}</b></pre></div>
HTML
}
