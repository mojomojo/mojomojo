package MojoMojo;

use strict;
use utf8;
use Path::Class 'file';

use Catalyst qw/            Authentication
		Cache::FileCache    Email
	    FillInForm	        FormValidator	    
		Session		        Session::Store::File
		Singleton           Session::State::Cookie
		Static::Simple	    SubRequest	    
		UploadProgress	    Unicode 
		Authentication::Store::DBIC 
		ConfigLoader	    Authentication::Credential::Password 
		/;

use MojoMojo::Formatter::Wiki;
use Module::Pluggable::Ordered 
    search_path => [qw/MojoMojo/], 
    except	=> qr/^MojoMojo::Plugin::/, 
    require	=> 1;

our $VERSION='0.999003';

MojoMojo->config->{authentication}{dbic} = {
    user_class => 'DBIC::Person',
    user_field => 'login',
    password_field => 'pass'
};

MojoMojo->setup();

MojoMojo->model('DBIC::Attachment')->result_source->schema->attachment_dir(MojoMojo->path_to('uploads').'');

=head1 NAME

MojoMojo - A Catalyst & DBIx::Class powered Wiki.

=head1 SYNOPSIS
    
  # Set up database (be sure to edit mojomojo.conf first)
  
  ./script/mojomojo_spawn_db.pl

  # Standalone mode

  ./bin/mojomo_server.pl

  # In apache conf
  <Location /mojomojo>
    SetHandler perl-script
    PerlHandler MojoMojo
  </Location>

=head1 DESCRIPTION

Mojomojo is a sort of content managment system, borrowing many concepts from
wikis and blogs. It allows you to maintain a full tree-structure of pages, 
and to interlink them in various ways. It has full version support, so you can
always go back to a previous version and see what's changed with a easy ajax-
based diff system. There are also a bunch of other features like a live AJAX
preview of editing, and RSS feeds for every wiki page.

=head1 METHODS

=head2 expand_wikiword wikiword

Proxy method for the L<MojoMojo::Formatter::Wiki> expand_wikiword method.

=cut

sub expand_wikiword {
    my $c = shift;
    return MojoMojo::Formatter::Wiki->expand_wikiword( @_ );
}

=head2 wikiword wikiword base

Format a wikiword as a link or as a wanted page, as appropriate.

=cut

sub wikiword {
    return MojoMojo::Formatter::Wiki->format_link( @_ );
}

=head2 pref key [value]

Find or create a preference key, update it if you pass a value
then return the current setting.

=cut

sub pref {
    my ( $c, $setting, $value ) = @_;
    $setting = $c->model('DBIC::Preference')->find_or_create(
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


=head2 fixw word

Clean up explicit wiki words.

=cut

sub fixw {
  my ( $c, $w ) = @_;
  $w =~ s/\s/\_/g;
  $w =~ s/[^\w\/\.]//g;
  return $w;
}

1;


=head2 OVERRIDDEN METHODS

=head2

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
    $c->req->base( URI->new($base) );
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

=head2 base_uri 

Return the base as an URI object.

=cut

sub base_uri {
  my $c=shift;
  return URI->new($c->req->base);
}


=head2 unicode 

format for unicode template use.

=cut

sub unicode {
    my ($c,$string)=@_;
    utf8::decode($string);
    return $string;
}

=head2 uri_for 
Overrides $c->uri_for to append path, if relative path is used

=cut

sub uri_for {
    my $c=shift;
   	unless ($_[0] =~ m/^\//) {
		 my $val=shift @_;
         my $prefix = $c->stash->{path} eq '/' ? '': '/';
    	 unshift(@_,$prefix . $c->stash->{path} . '.' . $val);
	}
    $c->NEXT::uri_for(@_);
}

=head1 AUTHORS

Marcus Ramberg C<marcus@thefeed.no>
David Naughton C<naughton@umn.edu>
Andy Grundman C<andy@hybridized.org>
Jonathan Rockway C<jrockway@jrockway.us>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut

