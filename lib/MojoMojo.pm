package MojoMojo;

use strict;
use utf8;
use Catalyst qw/-Debug FormValidator FillInForm Session::FastMmap Static SubRequest/;
use YAML ();
use Module::Pluggable::Ordered search_path => [qw/MojoMojo/], require => 1;
our $VERSION='0.05';

MojoMojo->config( YAML::LoadFile('/home/marcus/MojoMojo/mojomojo.yml') );

MojoMojo->action(

    '!default' => sub {
        my ( $self, $c ) = @_;
	$c->req->args([$self->pref('home_node')]);
        $c->forward( "!page/view" );
    },
    'favicon.ico' => sub {
        my ( $self, $c ) = @_;
        $c->serve_static;
    },

    '/^(\w+)\.(\w+)$/' => sub {
        my ( $self, $c ) = @_;
    	my ($page,$action) = @{ $c->request->snippets };
		$c->req->args([$page]);
        $c->forward( "!page/$action" );
    },
    '/^(\w+)$/' => sub {
        my ( $self, $c ) = @_;
    	my ($page) = @{ $c->request->snippets };
	$c->req->args([$page]);
        $c->forward( "!page/view" );
    },
    '.static' => sub {
        my ( $self, $c ) = @_;
	$c->res->headers->header( 'Cache-Control' => 'max-age=86400' );
        $c->serve_static;
    },

    '!end' => sub {
        my ( $self, $c ) = @_;
        $c->forward('!page/view')
          unless $c->stash->{template} || $c->res->output;
        $c->forward('MojoMojo::V::TT') unless $c->res->output;
    },

);

MojoMojo->plugins;

sub expand_wikiword {
    my ( $c, $word ) = @_;
    $word =~ s/([a-z])([A-Z])/$1 $2/g;
    $word =~ s/\_/ /g;
    return $word;
}

sub wikiword {
    my ( $c, $word, $base ) = @_;
    my $formatted = $c->expand_wikiword($word);
    if ( MojoMojo::M::Core::Page->search( node => $word )->next ) {
        if ($base) {
            return
qq{<a class="existingWikiWord" href="$base$word">$formatted</a> };
        }
        else {
            return qq{<a class="existingWikiWord" href="$word">$formatted</a> };
        }
    }
    else {
        if ($base) {
            return
qq{<span class="newWikiWord">$formatted<a href="$base$word">?</a></span>};
        }
        else {
            return
qq{<span class="newWikiWord">$formatted<a href="$word">?</a></span>};
        }
    }
}

sub pref {
    my ( $c, $setting, $value ) = @_;
    $setting =
      MojoMojo::M::Core::Preference->find_or_create( { prefkey => $setting } );
    if ( defined $value ) {
        $setting->prefvalue($value);
        $setting->update();
        return $value;
    }
    return ( defined $setting->prefvalue() ? $setting->prefvalue : "");
}

sub fixw { my ( $c, $w ) = @_; $w =~ s/\s/\_/g; return $w; }

sub Catalyst::Log::info {}
1;
