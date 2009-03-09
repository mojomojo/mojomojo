package MojoMojo::Schema;

use strict;
use warnings;

use Moose;

has 'attachment_dir' => ( is => 'rw', isa => 'Str' );

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces( default_resultset_class => '+MojoMojo::Schema::Base::ResultSet' );

=head1 NAME

MojoMojo::Schema

=head1 METHODS

=over 4

=item create_initial_data

Creates initial set of data in the database which is necessary to run MojoMojo.

=cut

sub create_initial_data {
    my ($schema, $config) = @_;
    print "Creating initial data\n";

    my $file = __PACKAGE__ . ".pm";
    $file =~ s{::}{/}g;
    my $path = $INC{$file};
    $path =~ s{Schema\.pm$}{I18N};

    require Locale::Maketext::Simple;
    Locale::Maketext::Simple->import(
        Decode => 1,
        Class  => 'MojoMojo',
        Path   => $path,
    );
    my $lang = $config->{'default_lang'} || 'en';
    $lang =~ s/\..*$//;
    loc_lang($lang);

    my @people = $schema->populate(
        'Person',
        [
            [
                qw/ active views photo login name email pass timezone born gender occupation industry interests movies music /
            ],
            [
                1, 0, 0, loc('anonymouscoward'), loc('Anonymous Coward'),
                '', '', '', 0, '', '', '', '', '', ''
            ],
            [ 1, 0, 0, 'admin', loc('Enoch Root'), '', 'admin', '', 0, '', '', '', '', '', '' ],
        ]
    );

    my @roles = $schema->populate(
        'Role',
        [
            [ qw/ name active / ],
            [ loc('Admins'), 1 ],
            [ loc('Users'),  1 ]
        ]
    );

    my @role_members = $schema->populate(
        'RoleMember',
        [
            [ qw/role person admin/ ],
            [ $roles[0]->id, $people[1]->id, 1 ]
        ]
    );

    my @path_permissions = $schema->populate(
        'PathPermissions',
        [
            [ qw/path role apply_to_subpages create_allowed delete_allowed edit_allowed view_allowed attachment_allowed / ],
            [ '/', $roles[0]->id, qw/ no yes yes yes yes yes yes/ ],
            [ '/', $roles[0]->id, qw/yes yes yes yes yes yes yes/ ]
        ]
    );

    my @prefs =
        $schema->populate( 'Preference',
        [ [qw/ prefkey prefvalue /], [ 'name', $config->{'name'} || "MojoMojo" ], [ 'admins', 'admin' ], [ 'theme', $config->{'theme'} || 'default' ] ] );

    my @pages = $schema->populate(
        'Page',
        [
            [qw/ version parent name name_orig depth lft rgt content_version /],
            [ undef, undef, '/',     '/',     0, 1, 5, undef ],
            [ undef, 1,     'help',  loc('Help'),  1, 2, 3, undef ],
            [ undef, 1,     'admin', 'Admin', 1, 4, 5, undef ],
        ]
    );

    my @pageversions = $schema->populate(
        'PageVersion',
        [
            [
                qw/page version parent parent_version name name_orig depth
                    content_version_first content_version_last creator status created
                    release_date remove_date comments/
            ],
            [
                1, 1, undef, undef, '/', '/', 0, undef, undef, $people[1]->id, '', 0, '', '', ''
            ],
            [
                2, 1, 1, undef, 'help', 'Help', 0, undef, undef, $people[1]->id, '', 0, '', '',
                ''
            ],
            [
                3, 1, 1, undef, 'admin', 'Admin', 0, undef, undef, $people[1]->id, '', 0, '',
                '', ''
            ],
        ]
    );

    my @content = $schema->populate(
        'Content',
        [
            [
                qw/ page version creator created body status release_date remove_date type abstract comments
                    precompiled /
            ],
            [
                1, 1, $people[1]->id, 0, loc('welcome message', "test"),
                'released', 1, 1, '', '', '', ''
            ],
            [
                2, 1, $people[1]->id, 0, loc('help message'),
                'released', 1, 1, '', '', '', ''
            ],
            [
                3, 1, $people[1]->id, 0, loc('admin home page'),
                'released', 1, 1, '', '', ''
            ],
        ]
    );

    $schema->resultset('Page')->update( { version         => 1 } );
    $schema->resultset('Page')->update( { content_version => 1 } );
    $schema->resultset('PageVersion')->update( { content_version_first => 1 } );
    $schema->resultset('PageVersion')->update( { content_version_last  => 1 } );

    print "Success!\n";
}

=back

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
