use Test::More;
BEGIN {
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBD::SQLite for testing' )
        : ( tests => 6 );
}

use lib qw(t/lib);
use MojoMojoTestSchema;

my $schema = MojoMojoTestSchema->init_schema(no_populate => 1);
$ENV{CATALYST_DEBUG}=0;
$ENV{MOJOMOJO_CONFIG}='t/var/mojomojo.yml';
use HTML::Entities;
use_ok( Catalyst::Test, 'MojoMojo' );
use Carp qw/verbose/;

is( get(encode_entities('/.jsrpc/render?content=').'\WikiWord'), 
                                                   '<p>WikiWord</p>' );
is( get(encode_entities('/.jsrpc/render?content=').'/[[wikiword]]'), 
                                                   '<p>/[[wikiword]]</p>' );
is( get(encode_entities('/.jsrpc/render?content=').'text+%3D+more'),
                                                   '<p>text = more</p>' );
is( get(encode_entities('/.jsrpc/render?content=').'WikiWord'), 
                                                   '<p><span class="newWikiWord">Wiki Word<a title="Not found. Click to create this page." href="http://localhost/WikiWord.edit">?</a></span></p>' );
is( get(encode_entities('/help.jsrpc/render?content=').'WikiWord'), 
                                                   '<p><span class="newWikiWord">Wiki Word<a title="Not found. Click to create this page." href="http://localhost/help/WikiWord.edit">?</a></span></p>' );
