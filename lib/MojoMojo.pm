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
MojoMojo->setup();

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

A wiki-based community software,
powered by Catalyst.

=head1 ACTIONS

=over 4

=item default (global)

default action - serve the home node

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    warn "called with ". join(" ",@_);
    $c->req->args([$c->pref('home_node')]);
    $c->forward( "/page/view" );
}

=item favicon 

serve favicon.ico statically.

=cut

sub favicon : Path('/favicon.ico') {
    my ( $self, $c ) = @_;
    $c->serve_static;
}

=item pageaction

regex to handle node requests. Will forward to requested action.

=cut

sub pageaction : Regex(^(\w[\w\/]+)\.(\w+)$) {
    my ( $self, $c ) = @_;
    my ($page,$action) = @{ $c->request->snippets };
    $c->req->args([$page]);
    $c->forward( "/page/$action" );
}

=item pageview

regex to handle node requests. Will forward to view action.

=cut

sub pageview : Regex(^(\w[\w\/]+)$) {
    my ( $self, $c ) = @_;
    my ($page) = @{ $c->request->snippets };
    $c->req->args([$page]);
    $c->forward( "/page/view" );
}

=item static

serve all files under /.static in the root as static files.

=cut

sub static : Path('/.static') {
    my ( $self, $c ) = @_;
    $c->res->headers->header( 'Cache-Control' => 'max-age=86400' );
      $c->serve_static;
}

=item end (global)

At the end of any request, forward to view unless there is a template
or response. then render the template. If param 'die' is passed, 
show a debug screen.

=back

=cut

sub end : Private {
    my ( $self, $c ) = @_;
    $c->forward('/page/view')
      unless $c->stash->{template} || $c->res->output;
    $c->forward('MojoMojo::V::TT') unless $c->res->output;
    die if $c->req->params->{die};
}

MojoMojo->plugins();

=head1 METHODS

=over 4

=item expand_wikiword wikiword

Add spaces to wiki words as appropriate

=cut

sub expand_wikiword {
    my ( $c, $word ) = @_;
    $word =~ s/([a-z])([A-Z])/$1 $2/g;
    $word =~ s/\_/ /g;
    return $word;
}

=item  wikiword wikiword [base]

format a wikiword as a link, or as a wanted page as appropriate.
If base is included, it will be use to form the link, otherwise
it will be relative.

=cut

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

=item pref key [value]

Find or create a preference key, update it if you pass a value
then return the current setting.

=cut

sub pref {
    my ( $c, $setting, $value ) = @_;
    $setting = MojoMojo::M::Core::Preference->find_or_create( 
                                    { prefkey => $setting } );
    if ( defined $value ) {
        $setting->prefvalue($value);
        $setting->update();
        return $value;
    }
    return ( defined $setting->prefvalue() ? 
             $setting->prefvalue : 
             "" );
}

=item prepare_home

Prepare mojomojo's homedir for first time use. Make directories
as apropriate, write config, create database, extract templates.

=cut

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

=item home [home]

set or return your home. unless you set a explicit home, it will
be derived from $ENV{MOJOMO_HOME}, or failing that, a homedir will 
be made in the current user's home directory.

=cut

sub home { 
    my ($class,$home)=@_;
    # Set a new home
    return $class->config(home=>$home) if $home;   
    # Has a home;
    return $class->config->{home} if $class->config->{home}; 
    if ($ENV{MOJOMOJO_HOME} && -w $ENV{MOJOMOJO_HOME}) {
        $class->config(home=>$ENV{MOJOMOJO_HOME});
    } elsif ( -w $ENV{HOME} ) {
        # got writeable home, so we'll try to store it there
        if (-w $ENV{HOME} ."/Library/Application Support") {
            # Mac style
            $class->config(home=>$ENV{HOME}.
                           "/Library/Application Support/MojoMojo");
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

=item fixw word

replace spaces in a given word with underscores.

=cut

sub fixw { my ( $c, $w ) = @_; $w =~ s/\s/\_/g; return $w; }

# Disable performance info
#sub Catalyst::Log::info {}

1;



=back

=head1 AUTHOR

Marcus Ramberg C<marcus@thefeed.no>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

