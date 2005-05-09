package MojoMojo;

require HTTP::Daemon; $HTTP::Daemon::PROTO = "HTTP/1.0";
use strict;
use utf8;
use Catalyst qw/-Debug FormValidator FillInForm Session::FastMmap 
                Static SubRequest Authentication::CDBI Prototype 
                Singleton Unicode/;
use MojoMojo::Search::Plucene;
use YAML ();
use Module::Pluggable::Ordered search_path => [qw/MojoMojo/], require => 1;
our $VERSION='0.05';

MojoMojo->prepare_home();
MojoMojo->config( YAML::LoadFile(MojoMojo->config->{home}.'/mojomojo.yml') );
MojoMojo->config( authentication => {
                    user_class     => 'MojoMojo::M::Core::Person',
                    user_field     => 'login',
                    password_field => 'pass'});

MojoMojo->config ( no_url_rewrite=>1 );
MojoMojo->setup();
MojoMojo->prepare_search_index();

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

Wiki-based community software,
powered by Catalyst.

=head1 ACTIONS

=over 4

=item default (global)

default action - serve the home node

=cut

sub default : Private {
    my ( $self, $c ) = @_;
    warn "called with ". join(" ",@_);
    $c->req->args( ['/'] );
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

regex to handle requests for actions on nodes. Will forward to 
requested action in the page controller.

=cut

sub pageaction : Regex(^([\w\/]*)\.(\w+)$) {
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
    $c->forward('MojoMojo::V::TT') unless $c->res->body;
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

=item  wikiword wikiword base

Format a wikiword as a link or as a wanted page, as appropriate.

=cut

sub wikiword {
    my ( $c, $word, $base ) = @_;
    $c=MojoMojo->context unless ref $c;
    # make sure that base url has no trailing slash, since
    # the page path will have a leading slash
    my $url = $base;
    $word = URI->new_abs( $word, $c->stash->{page}->path."/" ) if($c->stash->{page} && 
                                       ref $c->stash->{page} eq 'MojoMojo::M::Core::Page' &&
                                      $word !~ m|^/|) ;
    $c->log->debug("and the word is $word");
    $url =~ s/[\/]+$//;
    my ($path_pages, $proto_pages) = MojoMojo::M::Core::Page->path_pages( $word );
    # use the normalized path string returned by path_pages:
    my $formatted ;
    if (@$proto_pages)
    {
        my $proto_page = pop @$proto_pages;
        $formatted = $c->expand_wikiword($proto_page->{name});
        $url .= $proto_page->{path};
    }
    else
    {
        my $page = pop @$path_pages;
        $formatted = $c->expand_wikiword($page->name);
        $url .= $page->path;
        return qq{<a class="existingWikiWord" href="$url">$formatted</a> };
    }

    return qq{<span class="newWikiWord">$formatted<a href="$url">?</a></span>};
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
    my $home=$self->config->{home};
    return unless $home;
    return if -f $home.'/mojomojo.yml';
    for (qw( db uploads logs root )) {
        mkdir $home.'/'.$_ unless -w $home.'/'.$_;
    }
    YAML::DumpFile($home.'/mojomojo.yml',{
      name => 'MojoMojo',
      root => $home.'/root',
      dsn => 'dbi:SQLite:'.$home.'/db/sqlite2/mojomojo.db'});
}

=item prepare_search_index

Create a new Plucene search index from all pages in the database.
Will do nothing if the index already exists.

=cut

sub prepare_search_index {
    my $self = shift;
    my $index = $self->config->{home} . "/plucene";
    return if (-e $index . "/segments");
    
    # Plucene::Simple doesn't seem to tell Plucene to create a new index properly,
    # so we have to create a new segments file ourselves
    open SEGMENTS, ">$index/segments";
    close SEGMENTS;

    my $p = MojoMojo::Search::Plucene->open($index);
    
    $self->log->info( "Initializing Plucene search index..." ) if $self->debug;
    # loop through all latest-version pages
    my $count = 0;
    my $it = MojoMojo::M::Core::Page->retrieve_all;
    while ( my $page = $it->next ) {
        $p->update_index( $page );
        $count++;
    }
    
    $p->optimize;

    $self->log->info( "Indexed $count pages" ) if $self->debug;
}
    

=item fixw word

replace spaces in a given word with underscores.

=cut

sub fixw { my ( $c, $w ) = @_; $w =~ s/\s/\_/g; return $w; }

# Disable performance info
#sub Catalyst::Log::info {}

1;

=back

=head2 OVERRIDDEN METHODS

=over 4

=item prepare_path

strip last char from $c->req->path;

=cut

sub prepare_path {
    my $c = shift;
    $c->NEXT::prepare_path;
    my $path=$c->req->base;
    $path =~s|/+$||;
    $c->log->debug('Path is:'.$path);
    $c->req->base($path);
}

=back

=head1 AUTHORS

Marcus Ramberg C<marcus@thefeed.no>
David Naughton C<naughton@umn.edu>
Andy Grundman C<andy@hybridized.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

