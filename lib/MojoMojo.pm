package MojoMojo;

use strict;
use utf8;
use Catalyst qw/-Debug FormValidator FillInForm Session::FastMmap Static/;
use YAML ();

MojoMojo->config( YAML::LoadFile('/home/marcus/MojoMojo/mojomojo.yml') );

MojoMojo->action(

    '!default' => sub {
        my ( $self, $c ) = @_;
        $c->serve_static;
    },

    '!end' => sub {
        my ( $self, $c ) = @_;
        $c->forward('index')
          unless $c->stash->{template} || $c->res->output;
        $c->forward('MojoMojo::V::TT') unless $c->res->output;
    },

    'index' => sub {
        my ( $self, $c ) = @_;
        $c->res->redirect( $c->req->base . 'page/view/FrontPage' );
    },

);

sub expand_wikiword {
    my ( $c, $word ) = @_;
    $word =~ s/([a-z])([A-Z])/$1 $2/g;
    $word =~ s/\_/ /g;
    return $word;
}

sub wikiword {
    my ( $c, $word, $base ) = @_;
    my $formatted = $c->expand_wikiword($word);
    if ( MojoMojo::Page->search( node => $word )->next ) {
        if ($base) {
            return
qq{<a class="existingWikiWord" href="$base/page/view/$word">$formatted</a> };
        }
        else {
            return qq{<a class="existingWikiWord" href="$word">$formatted</a> };
        }
    }
    else {
        if ($base) {
            return
qq{<span class="newWikiWord">$formatted<a href="$base/page/view/$word">?</a></span>};
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
      MojoMojo::M::CDBI::Preference->find_or_create( { prefkey => $setting } );
    if ( defined $value ) {
        $setting->prefvalue($value);
        $setting->update();
        return $value;
    }
    return $setting->prefvalue();
}

sub fixw { my ( $c, $w ) = @_; $w =~ s/\s/\_/g; return $w; }

1;
