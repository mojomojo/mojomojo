use Test::More tests => 17;
use HTML::Entities;
use_ok( Catalyst::Test, 'MojoMojo' );
use Carp qw/verbose/;

is( get(encode_entities('/.jsrpc/render?content=').'<pre>[[wikiword]]<pre>'), 
                                                   '<pre>[[wikiword]]</pre>' );
is( get(encode_entities('/.jsrpc/render?content=').'\WikiWord'), 
                                                   '<p>WikiWord</p>' );
is( get(encode_entities('/.jsrpc/render?content=').'\[[wikiword]]'), 
                                                   '<p>[[wikiword]]</p>' );
is( get(encode_entities('/.jsrpc/render?content=').'\[[WikiWord]]'), 
                                                   '<p>[[WikiWord]]</p>' );
