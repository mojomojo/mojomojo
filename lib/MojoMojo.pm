package MojoMojo;

use strict;
use utf8;
use Catalyst qw/-Debug FormValidator FillInForm Session::FastMmap Static SubRequest Authentication::CDBI/;
use YAML ();
use Module::Pluggable::Ordered search_path => [qw/MojoMojo/], require => 1;
our $VERSION='0.05';

MojoMojo->prepare_home();
MojoMojo->config( YAML::LoadFile(MojoMojo->home().'/mojomojo.yml') );
MojoMojo->config( authentication => {
                    user_class     => 'MojoMojo::M::Core::User',
                    user_field     => 'login',
                    password_field => 'pass'});
   
MojoMojo->config ( no_url_rewrite=>1 );

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

    '/^(\w[\w\/]+)\.(\w+)$/' => sub {
        my ( $self, $c ) = @_;
        my ($page,$action) = @{ $c->request->snippets };
        $c->req->args([$page]);
        $c->forward( "!page/$action" );
    },
    '/^(\w[\w\/]+)$/' => sub {
        my ( $self, $c ) = @_;
        my ($page) = @{ $c->request->snippets };
        $c->req->args([$page]);
        $c->forward( "!page/view" );
    },
    '.static' => sub {
        my ( $self, $c ) = @_;
        $c->res->headers->header( 'Cache-Control' => 'max-age=86400' );
        if ($c->req->args->[0] =~ m/\.css$/) { 
          $c->serve_static('text/css');
        } else {
          $c->serve_static;
        }
    },

    '!end' => sub {
        my ( $self, $c ) = @_;
        $c->forward('!page/view')
          unless $c->stash->{template} || $c->res->output;
        $c->forward('MojoMojo::V::TT') unless $c->res->output;
        die if $c->req->params->{die};
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
sub prepare_home {
    my $self=shift;
    my $home=$self->home;
    return unless $home;
    return if -f $home.'/mojomojo.yml';
    for (qw( db uploads logs root )) {
        mkdir $home.'/'.$_ unless -w $home.'/'.$_;
    }
    YAML::DumpFile($home.'/mojomojo.yml',{
      name => 'MojoMojo',
      root => $home.'/root',
      dsn => 'dbi:SQLite2:'.$home.'/db/mojomojo.db'});
}

sub home { 
  my ($class,$home)=@_;
  return $class->config(home=>$home) if $home;   # Set a new home
  return $class->config->{home} if $class->config->{home}; # Has a home;
  if ($ENV{MOJOMOJO_HOME} && -w $ENV{MOJOMOJO_HOME}) {
    $class->config(home=>$ENV{MOJOMOJO_HOME});
  } elsif ( -w $ENV{HOME} ) {
  # got writeable home, so we'll try to store it there
    if (-w $ENV{HOME} ."/Library/Application Support") {
    # Mac style
      $class->config(home=>$ENV{HOME}."/Library/Application Support/MojoMojo");
    } else {
    # Unix Style
      $class->config(home=>$ENV{HOME}."/.mojomojo");
    }
    mkdir $class->config->{home} unless 
       -w $class->config->{home};
  } else {
    die "Can't find a a place to write my settings. ".
    "Perhaps you need to set the MOJOMOJO_HOME ENV variable?";
  }
  return $class->config->{home};
}

sub fixw { my ( $c, $w ) = @_; $w =~ s/\s/\_/g; return $w; }

sub Catalyst::Log::info {}

1;

=head1 MojoMojo - A fancy wiki, powered by Catalyst

=head1 SYNOPSIS

  # on the command line 
  ./bin/server.pl

  # In apache conf
  <Location /mojomojo>
    SetHandler perl-script
    PerlHandler MojoMojo
  </Location>

=head1 DESCRIPTION

A fancy wiki, powered by Catalyst.

=head1 AUTHOR

Marcus Ramberg C<marcus@thefeed.no>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

