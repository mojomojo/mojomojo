package MojoMojo;

use strict;
use Path::Class 'file';

use Catalyst qw/
    ConfigLoader
    Authentication
    Cache
    Session
    Session::Store::Cache
    Session::State::Cookie
    Static::Simple
    SubRequest
    Unicode
    I18N
    Setenv
    /;

use Storable;
use Digest::MD5;
use Data::Dumper;
use DateTime;
use MRO::Compat;
use DBIx::Class::ResultClass::HashRefInflator;
use Encode ();
use URI::Escape ();
use MojoMojo::Formatter::Wiki;
use Module::Pluggable::Ordered
    search_path => 'MojoMojo::Formatter',
    except      => qr/^MojoMojo::Plugin::/,
    require     => 1;

our $VERSION = '1.05';
use 5.008004;

MojoMojo->config->{authentication}{dbic} = {
    user_class     => 'DBIC::Person',
    user_field     => 'login',
    password_field => 'pass'
};
MojoMojo->config->{default_view}='TT';
MojoMojo->config->{'Plugin::Cache'}{backend} = {
    class => "Cache::FastMmap",
    unlink_on_exit => 1,
    share_file => '' . Path::Class::file(
        File::Spec->tmpdir,
        'mojomojo-sharefile-'.Digest::MD5::md5_hex(MojoMojo->config->{home})
    ),
};

__PACKAGE__->config( authentication => {
    default_realm => 'members',
    use_session   => 1,
    realms => {
        members => {
            credential => {
                class               => 'Password',
                password_field      => 'pass',
                password_type       => 'hashed',
                password_hash_type  => 'SHA-1',
            },
            store => {
                class      => 'DBIx::Class',
                user_class => 'DBIC::Person',
            },
        },
    }
});

__PACKAGE__->config('Controller::HTML::FormFu' => {
    languages_from_context => 1,
    localize_from_context  => 1,
});

__PACKAGE__->config( setup_components => {
    search_extra => [ '::Extensions' ],
});

MojoMojo->setup();

# Check for deployed database
my $has_DB = 1;
my $NO_DB_MESSAGE =<<"EOF";

    ***********************************************
    ERROR. Looks like you need to deploy a database.
    Run script/mojomojo_spawn_db.pl
    ***********************************************

EOF
eval { MojoMojo->model('DBIC')->schema->resultset('MojoMojo::Schema::Result::Person')->next };
if ($@ ) {
    $has_DB = 0;
    warn $NO_DB_MESSAGE;
    warn "(Error: $@)";
}

MojoMojo->model('DBIC')->schema->attachment_dir( MojoMojo->config->{attachment_dir}
        || MojoMojo->path_to('uploads') . '' );

=head1 NAME

MojoMojo - A Wiki with a tree

=head1 SYNOPSIS

  # Set up database (see mojomojo.conf first)

  ./script/mojomojo_spawn_db.pl

  # Standalone mode

  ./script/mojomo_server.pl

  # In apache conf
  <Location /mojomojo>
    SetHandler perl-script
    PerlHandler MojoMojo
  </Location>

=head1 DESCRIPTION

Mojomojo is a content management system, borrowing many concepts from
wikis and blogs. It allows you to maintain a full tree-structure of pages,
and to interlink them in various ways. It has full version support, so you can
always go back to a previous version and see what's changed with an easy diff
system. There are also a some of useful features like live AJAX preview while
editing, tagging, built-in fulltext search, image galleries, and RSS feeds
for every wiki page.

To find out more about how you can use MojoMojo, please visit
L<http://mojomojo.org/> or read the installation instructions in
L<MojoMojo::Installation> to try it out yourself.

=head1 METHODS

=head2 prepare

Accomodate a forcing of SSL if needed in a reverse proxy setup.

=cut

sub prepare {
    my $self = shift->next::method(@_);
    if ( $self->config->{force_ssl} ) {
        my $request = $self->request;
        $request->base->scheme('https');
        $request->uri->scheme('https');
    }
    return $self;
}


=head2 ajax

Return whether the request is an AJAX one (used by the live preview,
for example), as opposed to a rgular request (such as one used to view
a page).

=cut

sub ajax {
    my ($c) = @_;
    return $c->req->header('x-requested-with')
        && $c->req->header('x-requested-with') eq 'XMLHttpRequest';
}

=head2 expand_wikilink

Proxy method for the L<MojoMojo::Formatter::Wiki> expand_wikilink method.

=cut

sub expand_wikilink {
    my $c = shift;
    return MojoMojo::Formatter::Wiki->expand_wikilink(@_);
}

=head2 wikiword

Format a wikiword as a link or as a wanted page, as appropriate.

=cut

sub wikiword {
    return MojoMojo::Formatter::Wiki->format_link(@_);
}

=head2 pref

Find or create a preference key. Update it if a value is passed, then
return the current setting.

=cut

sub pref {
    my ( $c, $setting, $value ) = @_;

    return unless $setting;

    # Unfortunately there are MojoMojo->pref() calls in
    # MojoMojo::Schema::Result::Person which makes it hard
    # to get cache working for those calls - so we'll just
    # not use caching for those calls.
    return $c->pref_cached( $setting, $value ) if ref($c) eq 'MojoMojo';

    $setting = $c->model('DBIC::Preference')->find_or_create( { prefkey => $setting } );
    if ( defined $value ) {
        $setting->prefvalue($value);
        $setting->update();
        return $value;
    }
    return (
        defined $setting->prefvalue()
        ? $setting->prefvalue
        : ""
    );
}

=head2 pref_cached

Get preference key/value from cache if possible.

=cut

sub pref_cached {
    my ( $c, $setting, $value ) = @_;

    # Already in cache and no new value to set?
    if ( defined $c->cache->get($setting) and not defined $value ) {
        return $c->cache->get($setting);
    }
    # Check that we have a database, i.e. script/mojomojo_spawn_db.pl was run.
    my $row;
    $row = $c->model('DBIC::Preference')->find_or_create( { prefkey => $setting } );

    # Update database
    $row->update( { prefvalue => $value } ) if defined $value;

    my $prefvalue= $row->prefvalue();

    # if no entry in preferences, try get one from config or get default value
    unless ( defined $prefvalue) {

      if ($setting eq 'main_formatter' ) {
        $prefvalue = defined $c->config->{'main_formatter'}
                     ? $c->config->{'main_formatter'}
                     : 'MojoMojo::Formatter::Markdown';
      } elsif ($setting eq 'default_lang' ) {
        $prefvalue = defined $c->config->{$setting}
                     ? $c->config->{$setting}
                     : 'en';
      } elsif ($setting eq 'name' ) {
        $prefvalue = defined $c->config->{$setting}
                     ? $c->config->{$setting}
                     : 'MojoMojo';
      } elsif ($setting eq 'theme' ) {
        $prefvalue = defined $c->config->{$setting}
                     ? $c->config->{$setting}
                     : 'default';
      } elsif ($setting =~ /^(enforce_login|check_permission_on_view)$/ ) {
        $prefvalue = defined $c->config->{'permissions'}{$setting}
                     ? $c->config->{'permissions'}{$setting}
                     : 0;
      } elsif ($setting =~ /^(cache_permission_data|create_allowed|delete_allowed|edit_allowed|view_allowed|attachment_allowed)$/ ) {
        $prefvalue = defined $c->config->{'permissions'}{$setting}
                     ? $c->config->{'permissions'}{$setting}
                     : 1;
      } else {
        $prefvalue = $c->config->{$setting};
      }

    }

    # Update cache
    $c->cache->set( $setting => $prefvalue );

    return $c->cache->get($setting);
}

=head2 fixw

Clean up wiki words: replace spaces with underscores and remove non-\w, / and .
characters.

=cut

sub fixw {
    my ( $c, $w ) = @_;
    $w =~ s/\s/\_/g;
    $w =~ s/[^\w\/\.]//g;
    return $w;
}

=head2 tz

Convert timezone

=cut

sub tz {
    my ( $c, $dt ) = @_;
    if ( $c->user && $c->user->timezone ) {
        eval { $dt->set_time_zone( $c->user->timezone ) };
    }
    return $dt;
}

=head2 prepare_action

Provide "No DB" message when one needs to spawn the db (script/mojomojo_spawn.pl).

=cut

sub prepare_action {
    my $c = shift;

    if ($has_DB) {
        $c->next::method(@_);
    }
    else {
        $c->res->status( 404 );
        $c->response->body($NO_DB_MESSAGE);
        return;
    }
}

=head2 prepare_path

We override this method to work around some of Catalyst's assumptions about
dispatching. Since MojoMojo supports page namespaces
(e.g. C</parent_page/child_page>), with page paths that always start with C</>,
we strip the trailing slash from C<< $c->req->base >>. Also, since MojoMojo
indicates actions by appending a C<.$action> to the path
(e.g. C</parent_page/child_page.edit>), we remove the page path and save it in
C<< $c->stash->{path} >> and reset C<< $c->req->path >> to C<< $action >>.
We save the original URI in C<< $c->stash->{pre_hacked_uri} >>.

=cut

sub prepare_path {
    my $c = shift;
    $c->next::method(@_);
    $c->stash->{pre_hacked_uri} = $c->req->uri->clone;
    my $base = $c->req->base;
    $base =~ s|/+$||;
    $c->req->base( URI->new($base) );
    my ( $path, $action );
    $path = $c->req->path;

    if( $path =~ /^special(?:\/|$)(.*)/ ) {
        $c->stash->{path} = $path;
        $c->req->path($1);
    } else {
        # find the *last* period, so that pages can have periods in their name.
        # This fixes http://github.com/marcusramberg/mojomojo/issues/#issue/58
        my $index = index( $path, '.' );

        if ( $index == -1 ) {

            # no action found, default to view
            $c->stash->{path} = $path;
            $c->req->path('view');
        }
        else {

            # set path in stash, and set req.path to action
            $c->stash->{path} = substr( $path, 0, $index );
            $c->req->path( substr( $path, $index + 1 ) );
        }
    }
    $c->stash->{path}='/'.$c->stash->{path} unless ($path=~m!^/!);
}

=head2 base_uri

Return C<< $c->req->base >> as an URI object.

=cut

sub base_uri {
    my $c = shift;
    return URI->new( $c->req->base );
}

=head2 uri_for

Override C<< $c->uri_for >> to append path, if a relative path is used.

=cut

sub uri_for {
    my $c = shift;
    unless ( $_[0] =~ m/^\// ) {
        my $val = shift @_;
        my $prefix = $c->stash->{path} =~ m|^/| ? '' : '/';
        unshift( @_, $prefix . $c->stash->{path} . '.' . $val );
    }

    # do I see unicode here?
    if (Encode::is_utf8($_[0])) {
        $_[0] = join('/', map { URI::Escape::uri_escape_utf8($_) } split(/\//, $_[0]) );
    }

    my $res = $c->next::method(@_);
    $res->scheme('https') if $c->config->{'force_ssl'};
    return $res;
}

=head2 uri_for_static

C</static/> has been remapped to C</.static/>.

=cut

sub uri_for_static {
    my ( $self, $asset ) = @_;
     return 
        ( defined($self->config->{static_path} ) 
     ?  $self->config->{static_path} . $asset 
     :  $self->uri_for('/.static', $asset) );
}
=head2 _cleanup_path

Lowercase the path and remove any double-slashes.

=cut

sub _cleanup_path {
    my ( $c, $path ) = @_;
    ## Make some changes to the path - we have to do this
    ## because path is not always cleaned up before we get it:
    ## sometimes we get caps, other times we don't. Permissions are
    ## set using lowercase paths.

    ## lowercase the path - and ensure it has a leading /
    my $searchpath = lc($path);

    # clear out any double-slashes
    $searchpath =~ s|//|/|g;

    return $searchpath;
}

=head2 _expand_path_elements

Generate all the intermediary paths to C</path/to/a/page>, starting from C</>
and ending with the complete path:

    /
    /path
    /path/to
    /path/to/a
    /path/to/a/page

=cut    

sub _expand_path_elements {
    my ( $c, $path ) = @_;
    my $searchpath = $c->_cleanup_path( $path );

    my @pathelements = split '/', $searchpath;

    if ( @pathelements && $pathelements[0] eq '' ) {
        shift @pathelements;
    }

    my @paths_to_check = ('/');

    my $current_path = '';

    foreach my $pathitem (@pathelements) {
        $current_path .= "/" . $pathitem;
        push @paths_to_check, $current_path;
    }

    return @paths_to_check;
}

=head2 get_permissions_data

Permissions are checked prior to most actions, including C<view> if that is
turned on in the configuration. The permission system works as follows:

=over

=item 1.

There is a base set of rules which may be defined in the application
config. These are:

    $c->config->{permissions}{view_allowed} = 1; # or 0
    
Similar entries exist for C<delete>, C<edit>, C<create> and C<attachment>.
If these config variables are not defined, the default is to allow anyone 
to do anything.

=item 2.

Global rules that apply to everyone may be specified by creating a
record with a role id of 0.

=item 3.

Rules are defined using a combination of path(s)?, and role and may be
applied to subpages or not.

TODO: clarify.

=item 4.

All rules matching a given user's roles and the current path are used to
determine the final yes/no on each permission. Rules are evaluated from
least-specific path to most specific. This means that when checking
permissions on C</foo/bar/baz>, permission rules set for C</foo> will be
overridden by rules set on C</foo/bar> when editing C</foo/bar/baz>. When two
rules (from different roles) are found for the same path prefix, explicit
C<allow>s override C<deny>s. Null entries for a given permission are always
ignored and do not affect the permissions defined at earlier level. This
allows you to change certain permissions (such as C<create>) only while not
affecting previously determined permissions for the other actions. Finally -
C<apply_to_subpages> C<yes>/C<no> is exclusive, meaning that a rule for C</foo> with
C<apply_to_subpages> set to C<yes> will apply to C</foo/bar> but not to C</foo>
alone. The endpoint in the path is always checked for a rule explicitly for that
page - meaning C<apply_to_subpages = no>.

=back

=cut

sub get_permissions_data {
    my ( $c, $current_path, $paths_to_check, $role_ids ) = @_;

    # default to roles for current user
    $role_ids ||= $c->user_role_ids( $c->user );

    my $permdata;

    ## Now that we have our path elements to check, we have to figure out how we are accessing them.
    ## If we have caching turned on, we load the perms from the cache and walk the tree.
    ## Otherwise we pull what we need out of the DB. The structure is:
    # $permdata{$pagepath} = {
    #     admin => {
    #         page => {
    #             create => 'yes',
    #             delete => 'yes',
    #             view => 'yes',
    #             edit => 'yes',
    #             attachment => 'yes',
    #         },
    #         subpages => {
    #             create => 'yes',
    #             delete => 'yes',
    #             view => 'yes',
    #             edit => 'yes',
    #             attachment => 'yes',
    #         },
    #     },
    #     users => .....
    # }
    if ( $c->pref('cache_permission_data') ){
        $permdata = $c->cache->get('page_permission_data');
    }

    # If we don't have any permissions data, we have a problem. We need to load it.
    # We have two options here - if we are caching, we will load everything and cache it.
    # If we are not - then we load just the bits we need.
    if ( !$permdata ) {
        # Initialize $permdata as a reference or we end up with an error
        # when we try to dereference it further down.  The error we're avoiding is:
        # Can't use string ("") as a HASH ref while "strict refs"
        $permdata = {};
        
        ## Either the data hasn't been loaded, or it's expired since we used it last,
        ## so we need to reload it.
        my $rs =
            $c->model('DBIC::PathPermissions')
            ->search( undef, { order_by => 'length(path),role,apply_to_subpages' } );

        # If we are not caching, we don't return the whole enchilada.
        if ( ! $c->pref('cache_permission_data') ) {
            ## this seems odd to me - but that's what the DBIx::Class says to do.
            $rs = $rs->search( { role => $role_ids } ) if $role_ids;
            $rs = $rs->search(
                {
                    '-or' => [
                        {
                            path              => $paths_to_check,
                            apply_to_subpages => 'yes'
                        },
                        {
                            path              => $current_path,
                            apply_to_subpages => 'no'
                        }
                    ]
                }
            );
        }
        $rs->result_class('DBIx::Class::ResultClass::HashRefInflator');

        my $recordtype;
        while ( my $record = $rs->next ) {
            if ( $record->{'apply_to_subpages'} eq 'yes' ) {
                $recordtype = 'subpages';
            }
            else {
                $recordtype = 'page';
            }
            %{ $permdata->{ $record->{'path'} }{ $record->{'role'} }{$recordtype} } =
                map { $_ => $record->{ $_ . "_allowed" } }
                qw/create edit view delete attachment/;
        }
    }

    ## now we re-cache it - if we need to.  # !$c->cache('memory')->exists('page_permission_data')
    if ( $c->pref('cache_permission_data') ) {
        $c->cache->set( 'page_permission_data', $permdata );
    }

    return $permdata;
}

=head2 user_role_ids

Get the list of role ids for a user.

=cut

sub user_role_ids {
    my ( $c, $user ) = @_;

    ## always use role_id 0 - which is default role and includes everyone.
    my @role_ids = (0);

    if ( ref($user) ) {
        push @role_ids, map { $_->role->id } $user->role_members->all;
    }

    return @role_ids;
}

=head2 check_permissions

Check user permissions for a path.

=cut

sub check_permissions {
    my ( $c, $path, $user ) = @_;

    return {
        attachment  => 1,    create      => 1, delete      => 1,
        edit        => 1,    view        => 1,
    } if ($user && $user->is_admin);

    # if no user is logged in
    if (not $user) {
        # if anonymous user is allowed
        my $anonymous = $c->pref('anonymous_user');
        if ($anonymous) {
            # get anonymous user for no logged-in users
            $user = $c->model('DBIC::Person') ->search( {login => $anonymous} )->first;
        }
    }

    my @paths_to_check = $c->_expand_path_elements($path);
    my $current_path   = $paths_to_check[-1];

    my @role_ids = $c->user_role_ids( $user );

    my $permdata = $c->get_permissions_data($current_path, \@paths_to_check, \@role_ids);

    # rules comparison hash
    # allow everything by default
    my %rulescomparison = (
        'create' => {
            'allowed' => $c->pref('create_allowed'),
            'role' => '__default',
            'len'  => 0,
        },
        'delete' => {
            'allowed' => $c->pref('delete_allowed'),
            'role' => '__default',
            'len'  => 0,
        },
        'edit' => {
            'allowed' => $c->pref('edit_allowed'),
            'role' => '__default',
            'len'  => 0,
        },
        'view' => {
            'allowed' => $c->pref('view_allowed'),
            'role' => '__default',
            'len'  => 0,
        },
        'attachment' => {
            'allowed' => $c->pref('attachment_allowed'),
            'role' => '__default',
            'len'  => 0,
        },
    );

    ## The outcome of this loop is a combined permission set.
    ## The rule orders are essentially based on how specific the path
    ## match is.  More specific paths override less specific paths.
    ## When conflicting rules at the same level of path hierarchy
    ## (with different roles) are discovered, the grant is given precedence
    ## over the deny.  Note that more-specific denies will still
    ## override.
    my $permtype = 'subpages';
    foreach my $i ( 0 .. $#paths_to_check ) {
        my $path = $paths_to_check[$i];
        if ( $i == $#paths_to_check ) {
            $permtype = 'page';
        }
        foreach my $role (@role_ids) {
            if (   exists( $permdata->{$path} )
                && exists( $permdata->{$path}{$role} )
                && exists( $permdata->{$path}{$role}{$permtype} ) )
            {

                my $len = length($path);

                foreach my $perm ( keys %{ $permdata->{$path}{$role}{$permtype} } ) {

                    ## if the xxxx_allowed column is null, this permission is ignored.
                    if ( defined( $permdata->{$path}{$role}{$permtype}{$perm} ) ) {
                        if ( $len == $rulescomparison{$perm}{'len'} ) {
                            if ( $permdata->{$path}{$role}{$permtype}{$perm} eq 'yes' ) {
                                $rulescomparison{$perm}{'allowed'} = 1;
                                $rulescomparison{$perm}{'len'}     = $len;
                                $rulescomparison{$perm}{'role'}    = $role;
                            }
                        }
                        elsif ( $len > $rulescomparison{$perm}{'len'} ) {
                            if ( $permdata->{$path}{$role}{$permtype}{$perm} eq 'yes' ) {
                                $rulescomparison{$perm}{'allowed'} = 1;
                            }
                            else {
                                $rulescomparison{$perm}{'allowed'} = 0;
                            }
                            $rulescomparison{$perm}{'len'}  = $len;
                            $rulescomparison{$perm}{'role'} = $role;
                        }
                    }
                }
            }
        }
    }
  
    my %perms = map { $_ => $rulescomparison{$_}{'allowed'} } keys %rulescomparison;

    return \%perms;
}

=head2 check_view_permission

Check if a user can view a path.

=cut

sub check_view_permission {
    my $c = shift;

    return 1 unless $c->pref('check_permission_on_view');

    my $user;
    if ( $c->user_exists() ) {
        $user = $c->user->obj;
    }

    $c->log->info('Checking permissions') if $c->debug;

    my $perms = $c->check_permissions( $c->stash->{path}, $user );
    if ( !$perms->{view} ) {
        $c->stash->{message}
            = $c->loc( 'Permission Denied to view x', $c->stash->{page}->name );
        $c->stash->{template} = 'message.tt';
        return;
    }

    return 1;
}

my $search_setup_failed = 0;

MojoMojo->config->{index_dir} ||= MojoMojo->path_to('index');
MojoMojo->config->{attachment_dir} ||= MojoMojo->path_to('uploads');
MojoMojo->config->{root} ||= MojoMojo->path_to('root');
unless (-e MojoMojo->config->{index_dir}) {
    if (not mkdir MojoMojo->config->{index_dir}) {
       warn 'Could not make index directory <'.MojoMojo->config->{index_dir}.'> - FIX IT OR SEARCH WILL NOT WORK!';
       $search_setup_failed = 1;
    }
}
unless (-w MojoMojo->config->{index_dir}) {
    warn 'Require write access to index <'.MojoMojo->config->{index_dir}.'> - FIX IT OR SEARCH WILL NOT WORK!';
    $search_setup_failed = 1;
}

MojoMojo->model('Search')->prepare_search_index()
    if not -f MojoMojo->config->{index_dir}.'/segments' and not $search_setup_failed and not MojoMojo->pref('disable_search');

unless (-e MojoMojo->config->{attachment_dir}) {
    mkdir MojoMojo->config->{attachment_dir}
        or die 'Could not make attachment directory <'.MojoMojo->config->{attachment_dir}.'>';
}
die 'Require write access to attachment_dir: <'.MojoMojo->config->{attachment_dir}.'>'
    unless -w MojoMojo->config->{attachment_dir};

1;

=head1 SUPPORT

=over

=item *

L<http://mojomojo.org>

=item *

IRC: L<irc://irc.perl.org/mojomojo>.

=item *

Mailing list: L<http://mojomojo.2358427.n2.nabble.com/>

=item *

Commercial support and customization for MojoMojo is also provided by Nordaaker
Ltd. Contact C<arneandmarcus@nordaaker.com> for details.

=back

=head1 AUTHORS

Marcus Ramberg C<marcus@nordaaker.com>

David Naughton C<naughton@umn.edu>

Andy Grundman C<andy@hybridized.org>

Jonathan Rockway C<jrockway@jrockway.us>

A number of other contributors over the years:
https://www.ohloh.net/p/mojomojo/contributors

=head1 COPYRIGHT

Unless explicitly stated otherwise, all modules and scripts in this distribution are:
Copyright 2005-2010, Marcus Ramberg

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
