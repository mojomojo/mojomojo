package MojoMojo;

require HTTP::Daemon; $HTTP::Daemon::PROTO = "HTTP/1.0";
use strict;
use utf8;
use Path::Class 'file';

use Catalyst qw/-Debug FormValidator Session::FastMmap Static
                SubRequest Authentication::CDBI Prototype  Email
                Singleton Unicode::Encoding Cache::FileCache FillInForm/;
use MojoMojo::Search::Plucene;
use MojoMojo::Formatter::Wiki;

use YAML ();
use Module::Pluggable::Ordered search_path => [qw/MojoMojo/], except => qr/^MojoMojo::Plugin::/, require => 1;

our $VERSION='0.05';

MojoMojo->prepare_home();
MojoMojo->config( YAML::LoadFile( file( MojoMojo->config->{home},'/mojomojo.yml' ) ) );

MojoMojo->config->{auth_class} ||= 'MojoMojo::Plugin::DefaultAuth';
my $auth_class = MojoMojo->config->{auth_class};
eval "CORE::require $auth_class";
die "Couldn't require $auth_class : $@" if $@;
MojoMojo->config( authentication => {
                    user_class     => 'MojoMojo::M::Core::Person',
                    user_field     => 'login',
                    password_field => 'pass' } );

MojoMojo->config ( no_url_rewrite=>1 );
MojoMojo->config( cache => { storage=> MojoMojo->config->{home}.'/cache' } );
MojoMojo->config( encoding => 'UTF-8' ); # A valid Encode encoding

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


=item begin (builtin)

=cut

sub begin : Private {
    my ( $self, $c ) = @_;
    if ( $c->stash->{path} ) {
        my ( $path_pages, $proto_pages ) = MojoMojo::M::Core::Page->path_pages( $c->stash->{path} );
        @{$c->stash}{qw/ path_pages proto_pages /} = ( $path_pages, $proto_pages );
        $c->stash->{page} = $path_pages->[ @$path_pages - 1 ];
        $c->req->{user_id} && do {
            $c->stash->{user} = MojoMojo::M::Core::Person->retrieve( $c->req->{user_id} );
        };
    }
}

=item default (global)

default action - serve the home node

=cut

sub default : Private {
    my ( $self, $c )      = @_;
    $c->stash->{message}  = "Couldn't find that page, jimmy";
    $c->stash->{template} = 'message.tt';
}

=item end (builtin)

At the end of any request, forward to view unless there is a template
or response. then render the template. If param 'die' is passed, 
show a debug screen.

=cut

sub end : Private {
    my ( $self, $c ) = @_;
    return 1 if $c->response->status =~ /^3\d\d$/;
    return 1 if $c->response->body;
        if ($c->req->action ne 'static') {
                $c->res->header('Cache-Control','no-cache');
        }
    unless ( $c->response->content_type ) {
       $c->response->content_type('text/html; charset=utf-8');
    }
    if ( $c->request->param('rest') ) {
	$c->stash->{template} = 'rest/'.$c->stash->{template};
    }
    $c->forward( 'MojoMojo::V::TT' );
    unless ($c->res->body) {
	$c->stash->{message}  = 'No data returned';
	$c->stash->{template} = 'message.tt';
	$c->res->status(404);

    }
    die "debubbah" if $c->debug() && $c->req->params->{die};
}

=item auto

runs for all requests, checks if user is in need of validation, and 
intercepts the request if so.

=cut

sub auto : Private {
    my ($self,$c) = @_;
    return 1 unless $c->stash->{user};
    return 1 if $c->stash->{user}->active != -1;
    return 1 if $c->req->action eq 'logout';
    $c->stash->{template}='user/validate.tt';
}

=back

=head1 METHODS

=over 4

=item expand_wikiword wikiword

Add spaces to wiki words as appropriate

=cut

sub expand_wikiword {
    my $c = shift;
    return MojoMojo::Formatter::Wiki->expand_wikiword( @_ );
}

=item  wikiword wikiword base

Format a wikiword as a link or as a wanted page, as appropriate.

=cut

sub wikiword {
    return MojoMojo::Formatter::Wiki->format_link( @_ );
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
    for ( qw( db uploads logs root ) ) {
        mkdir $home.'/'.$_ unless -w $home.'/'.$_;
    }
    YAML::DumpFile( $home.'/mojomojo.yml',{
      name => 'MojoMojo',
      root => $home.'/root',
      dsn => 'dbi:SQLite:'.$home.'/db/sqlite/mojomojo.db'} );
}

=item prepare_search_index

Create a new Plucene search index from all pages in the database.
Will do nothing if the index already exists.

=cut

sub prepare_search_index {
    my $self = shift;
    my $index = $self->config->{home} . "/plucene";
    return if ( -e $index . "/segments" );

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

Clean up explicit wiki words.

=cut

sub fixw {
  my ( $c, $w ) = @_;
  $w =~ s/\s/\_/g;
  $w =~ s/[^\w\/\.]//g;
  return $w;
}

# Disable performance info
#sub Catalyst::Log::info {}

1;

=back

=head2 OVERRIDDEN METHODS

=over 4

=item prepare_path

We override this method to work around some of Catalyst's assumptions
about dispatching. Since MojoMojo supports page namespaces
(e.g. '/parent_page/child_page'), with page paths that
always start with '/', we strip the trailing slash from $c->req->base.
Also, since MojoMojo indicates actions by appending a '.$action' to
the path (e.g. '/parent_page/child_page.edit'), we remove the page
path and save it in $c->stash->{path} and reset $c->req->path to $action.
We save the original uri in $c->stash->{pre_hacked_uri}.

=cut

sub prepare_path {
    my $c = shift;
    $c->NEXT::prepare_path;
    $c->stash->{pre_hacked_uri} = $c->req->uri;
    my $base=$c->req->base;
    $base =~s|/+$||;
    $c->req->base($base);
    my ($path,$action);
    $path=$c->req->path;
    my $index=index($path,'.');
    if ($index==-1) {
      # no action found, default to view
      $c->stash->{path}=$path || '/';
      $c->req->path('view');
    } else {
      # set path in stash, and set req.path to action
      $c->stash->{path}='/'.substr($path,0,$index);
      $c->req->path(substr($path,$index+1));
    }
}

=item  base_uri 

Return the base as an URI object.

=cut

sub base_uri {
  my $c=shift;
  return URI->new($c->req->base);
}


=item unicode 

format for unicode template use.

=cut

sub unicode {
    my ($c,$string)=@_;
    utf8::decode($string);
    return $string;
}

=back

=head1 AUTHORS

Marcus Ramberg C<marcus@thefeed.no>
David Naughton C<naughton@umn.edu>
Andy Grundman C<andy@hybridized.org>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

