package MojoMojo;

use strict;
use Path::Class 'file';

use Catalyst qw/
    ConfigLoader
    Authentication
    Cache
    Email
    Session
    Session::Store::File
    Singleton
    Session::State::Cookie
    Static::Simple
    SubRequest
    Unicode
    I18N
    Setenv
    /;

use Storable;
use Data::Dumper;
use DBIx::Class::ResultClass::HashRefInflator;
use Encode ();
use URI::Escape ();
use MojoMojo::Formatter::Wiki;
use Module::Pluggable::Ordered
    search_path => [qw/MojoMojo/],
    except      => qr/^MojoMojo::Plugin::/,
    require     => 1;

our $VERSION = '0.999028';

MojoMojo->config->{authentication}{dbic} = {
    user_class     => 'DBIC::Person',
    user_field     => 'login',
    password_field => 'pass'
};
MojoMojo->config->{default_view}='TT';
MojoMojo->config->{cache}{backend} = {
    class => "Cache::FastMmap",
};

MojoMojo->setup();


MojoMojo->model('DBIC')->schema->attachment_dir( MojoMojo->config->{attachment_dir}
        || MojoMojo->path_to('uploads') . '' );

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
always go back to a previous version and see what's changed with an easy AJAX-
based diff system. There are also a bunch of other features like bult-in
fulltext search, live AJAX preview of editing, and RSS feeds for every wiki page.

To find out more about how you can use MojoMojo, please visit
http://mojomojo.org or read the installation instructions in
L<MojoMojo::Installation> to try it out yourself.

=cut

# Proxy method for the L<MojoMojo::Formatter::Wiki> expand_wikiword method.

sub ajax {
    my ($c) = @_;
    return $c->req->header('x-requested-with')
        && $c->req->header('x-requested-with') eq 'XMLHttpRequest';
}

sub expand_wikiword {
    my $c = shift;
    return MojoMojo::Formatter::Wiki->expand_wikiword(@_);
}

# Format a wikiword as a link or as a wanted page, as appropriate.

sub wikiword {
    return MojoMojo::Formatter::Wiki->format_link(@_);
}

# Find or create a preference key, update it if you pass a value
# then return the current setting.

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

# Get preference key/value from cache if possible.

sub pref_cached {
    my ( $c, $setting, $value ) = @_;

    # Already in cache and no new value to set?
    if ( defined $c->cache->get($setting) and not defined $value ) {
        return $c->cache->get($setting);
    }

    my $row = $c->model('DBIC::Preference')->find_or_create( { prefkey => $setting } );

    # Update database
    $row->update( { prefvalue => $value } ) if defined $value;

    # Update cache
    $c->cache->set(
          $setting => defined $row->prefvalue
        ? $row->prefvalue()
        : ""
    );

    return $c->cache->get($setting);
}

# Clean up explicit wiki words.

sub fixw {
    my ( $c, $w ) = @_;
    $w =~ s/\s/\_/g;
    $w =~ s/[^\w\/\.]//g;
    return $w;
}

# We override this method to work around some of Catalyst's assumptions
# about dispatching. Since MojoMojo supports page namespaces
# (e.g. '/parent_page/child_page'), with page paths that
# always start with '/', we strip the trailing slash from $c->req->base.
# Also, since MojoMojo indicates actions by appending a '.$action' to
# the path (e.g. '/parent_page/child_page.edit'), we remove the page
# path and save it in $c->stash->{path} and reset $c->req->path to $action.
# We save the original uri in $c->stash->{pre_hacked_uri}.

sub prepare_path {
    my $c = shift;
    $c->NEXT::prepare_path;
    $c->stash->{pre_hacked_uri} = $c->req->uri;
    my $base = $c->req->base;
    $base =~ s|/+$||;
    $c->req->base( URI->new($base) );
    my ( $path, $action );
    $path = $c->req->path;
    my $index = index( $path, '.' );

    if ( $index == -1 ) {

        # no action found, default to view
        $c->stash->{path} = $path || '/';
        $c->req->path('view');
    }
    else {

        # set path in stash, and set req.path to action
        $c->stash->{path} = '/' . substr( $path, 0, $index );
        $c->req->path( substr( $path, $index + 1 ) );
    }
}

# Return the base as an URI object.

sub base_uri {
    my $c = shift;
    return URI->new( $c->req->base );
}

# format for unicode template use.

sub unicode {
    my ( $c, $string ) = @_;
    utf8::decode($string);
    return $string;
}

# Override $c->uri_for to append path, if relative path is used

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

    $c->NEXT::uri_for(@_);
}

sub uri_for_static {
    my ( $self, $asset ) = @_;
    return ( $self->config->{static_path} || '/.static/' ) . $asset;
}

#  Permissions are checked prior to most actions. Including view if that is
#  turned on in the configuration. The permission system works as follows.
#  1. There is a base set of rules which may be defined in the application
#     config, these are:
#          $c->config->{permissions}{view_allowed} = 1; # or 0
#     similar entries exist for delete, edit, create and attachment.
#     if these config variables are not defined, default is to allow
#     anyone to do anything.
#
#   2. Global rules that apply to everyone may be specified by creating a
#      record with a role-id of 0.
#
#   3. Rules are defined using a combination of path, and role and may be
#      applied to subpages or not.
#
#   4. All rules matching a given user's roles and the current path are used to
#      determine the final yes/no on each permission. Rules are evaluated from
#      least-specific path to most specific. This means that when checking
#      permissions on /foo/bar/baz, permission rules set for /foo will be
#      overridden by rules set on /foo/bar when editing /foo/bar/baz. When two
#      rules (from different roles) are found for the same path prefix, explicit
#      allows override denys. Null entries for a given permission are always
#      ignored and do not effect the permissions defined at earlier level. This
#      allows you to change certain permissions (such as create) only while not
#      affecting previously determined permissions for the other actions. Finally -
#      apply_to_subpages yes/no is exclusive. Meaning that a rule for /foo with
#      apply_to_subpages set to yes will apply to /foo/bar but not to /foo alone.
#      The endpoint in the path is always checked for a rule explicitly for that
#      page - meaning apply_to_subpages = no.

sub _cleanup_path {
    my ( $c, $path ) = @_;
    ## make some changes to the path - We have to do this
    ## because path is not always cleaned up before we get it.
    ## sometimes we get caps, other times we don't.  permissions are
    ## set using lowercase paths.

    ## lowercase the path - and ensure it has a leading /
    my $searchpath = lc($path);

    # clear out any double-slashes
    $searchpath =~ s|//|/|g;

    return $searchpath;
}

sub _expand_path_elements {
    my ( $c, $path ) = @_;
    my $searchpath = $c->_cleanup_path( $path );

    my @pathelements = split '/', $searchpath;

    if ( @pathelements && $pathelements[0] eq '' ) {
        shift @pathelements;
    }

    my @paths_to_check = ('/');

    my $current_path;

    foreach my $pathitem (@pathelements) {
        $current_path .= "/" . $pathitem;
        push @paths_to_check, $current_path;
    }

    return @paths_to_check;
}

sub get_permissions_data {
    my ( $c, $current_path, $paths_to_check, $role_ids ) = @_;

    # default to roles for current user
    $role_ids ||= $c->user_role_ids( $c->user );

    my $permdata;

    ## ok - now that we have our path elements to check - we have to figure out how we are accessing them.
    ## If we have caching turned on, we load the perms from the cache and walk the tree.
    ## otherwise we pull what we need out of the db.
    # structure:   $permdata{$pagepath} = {
    #                                         admin => {
    #                                                   page => {
    #                                                               create => 'yes',
    #                                                               delete => 'yes',
    #                                                               view => 'yes',
    #                                                               edit => 'yes',
    #                                                               attachment => 'yes',
    #                                                           },
    #                                                   subpages => {
    #                                                               create => 'yes',
    #                                                               delete => 'yes',
    #                                                               view => 'yes',
    #                                                               edit => 'yes',
    #                                                               attachment => 'yes',
    #                                                           },
    #                                                  },
    #                                         users => .....
    #                                     }
    if ( $c->pref('cache_permission_data')    ne""
         ? $c->pref('cache_permission_data')
         : defined $c->config->{'permissions'}{'cache_permission_data'}
           ? $c->config->{'permissions'}{'cache_permission_data'}
           : 1) {
        $permdata = $c->cache->get('page_permission_data');
    }

    # if we don't have any permissions data, we have a problem. we need to load it.
    # we have two options here - if we are caching, we will load everything and cache it.
    # if we are not - then we load just the bits we need.
    if ( !$permdata ) {
        ## either the data hasn't been loaded, or it's expired since we used it last.
        ## so we need to reload it.
        my $rs =
            $c->model('DBIC::PathPermissions')
            ->search( undef, { order_by => 'length(path),role,apply_to_subpages' } );

        # if we are not caching, we don't return the whole enchilada.
        if ( ! $c->pref('cache_permission_data')    ne""
               ? $c->pref('cache_permission_data')
               : defined $c->config->{'permissions'}{'cache_permission_data'}
                 ? $c->config->{'permissions'}{'cache_permission_data'}
                 : 1) {
            ## this seems odd to me - but that's what the dbix::class says to do.
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
    if ( $c->pref('cache_permission_data')    ne""
         ? $c->pref('cache_permission_data')
         : defined $c->config->{'permissions'}{'cache_permission_data'}
           ? $c->config->{'permissions'}{'cache_permission_data'}
           : 1) {
        $c->cache->set( 'page_permission_data', $permdata );
    }

    return $permdata;
}

sub user_role_ids {
    my ( $c, $user ) = @_;

    ## always use role_id 0 - which is default role and includes everyone.
    my @role_ids = (0);

    if ( ref($user) ) {
        push @role_ids, map { $_->role->id } $user->role_members->all;
    }

    return @role_ids;
}

sub check_permissions {
    my ( $c, $path, $user ) = @_;

    return {
        attachment  => 1,    create      => 1, delete      => 1,
        edit        => 1,    view        => 1,
    } if ($user && $user->is_admin);

    my @paths_to_check = $c->_expand_path_elements($path);
    my $current_path   = $paths_to_check[-1];

    my @role_ids = $c->user_role_ids( $user );

    my $permdata = $c->get_permissions_data($current_path, \@paths_to_check, \@role_ids);

    # rules comparison hash
    # allow everything by default
    my %rulescomparison = (
        'create' => {
            'allowed' => (
                $c->pref('create_allowed') ne""
                ? $c->pref('create_allowed')
                : defined $c->config->{'permissions'}{'create_allowed'}
                  ? $c->config->{'permissions'}{'create_allowed'}
                  : 1
            ),
            'role' => '__default',
            'len'  => 0,
        },
        'delete' => {
            'allowed' => (
                $c->pref('delete_allowed') ne""
                ? $c->pref('delete_allowed')
                : defined $c->config->{'permissions'}{'delete_allowed'}
                  ? $c->config->{'permissions'}{'delete_allowed'}
                  : 1
            ),
            'role' => '__default',
            'len'  => 0,
        },
        'edit' => {
            'allowed' => (
                $c->pref('edit_allowed') ne""
                ? $c->pref('edit_allowed')
                : defined $c->config->{'permissions'}{'edit_allowed'}
                  ? $c->config->{'permissions'}{'edit_allowed'}
                  : 1
            ),
            'role' => '__default',
            'len'  => 0,
        },
        'view' => {
            'allowed' => (
                $c->pref('view_allowed') ne""
                ? $c->pref('view_allowed')
                : defined $c->config->{'permissions'}{'view_allowed'}
                  ? $c->config->{'permissions'}{'view_allowed'}
                  : 1
            ),
            'role' => '__default',
            'len'  => 0,
        },
        'attachment' => {
            'allowed' => (
                $c->pref('attachment_allowed') ne""
                ? $c->pref('attachment_allowed')
                : defined $c->config->{'permissions'}{'attachment_allowed'}
                  ? $c->config->{'permissions'}{'attachment_allowed'}
                  : 1
            ),
            'role' => '__default',
            'len'  => 0,
        },
    );

    ## the outcome of this loop is a combined permission set.
    ## The rule orders are basically based on how specific the path
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

my $search_setup_failed = 0;

MojoMojo->config->{index_dir}||=MojoMojo->path_to('index');
MojoMojo->config->{attachment_dir}||=MojoMojo->path_to('uploads');
unless (-e MojoMojo->config->{index_dir}) {
    mkdir(MojoMojo->config->{index_dir}) || warn 'Could not make index directory <'.MojoMojo->config->{index_dir}.'> FIX IT OR SEARCH WILL NOT WORK!' and $search_setup_failed = 1;
}
warn 'Require write access to index <'.MojoMojo->config->{index_dir}.'> - FIX IT OR SEARCH WILL NOT WORK!' and $search_setup_failed = 1 unless (-w MojoMojo->config->{index_dir});

MojoMojo->model('Search')->prepare_search_index() if not -f MojoMojo->config->{index_dir}.'/segments' and not $search_setup_failed and not MojoMojo->pref('disable_search');
unless (-e MojoMojo->config->{attachment_dir}) {
    mkdir(MojoMojo->config->{attachment_dir}) || die 'Could not make attachment directory <'.MojoMojo->config->{attachment_dir}.'>';
}
die 'Require write access to attachment_dir: <'.MojoMojo->config->{attachment_dir}.'>' unless (-w MojoMojo->config->{attachment_dir});

1;

=head1 SUPPORT

If you want to talk about MojoMojo, there's a irc channel, #mojomojo@irc.perl.org.
Commercial support and customization for MojoMojo is also provided by Nordaaker
Ltd. Contact C<arneandmarcus@nordaaker.com> for details.

=head1 AUTHORS

Marcus Ramberg C<marcus@nordaaker.com>

David Naughton C<naughton@umn.edu>

Andy Grundman C<andy@hybridized.org>

Jonathan Rockway C<jrockway@jrockway.us>

A number of other contributors over the years.

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
