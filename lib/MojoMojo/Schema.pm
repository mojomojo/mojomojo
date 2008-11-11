package MojoMojo::Schema;

use strict;
use warnings;

use Moose;

has 'attachment_dir' => ( is => 'rw', isa => 'Str' );

use base 'DBIx::Class::Schema';

__PACKAGE__->load_classes;

sub create_initial_data {
    my $schema = shift;
    print "Creating initial data\n";

    my @people = $schema->populate(
        'Person',
        [
            [
                qw/ active views photo login name email pass timezone born gender occupation industry interests movies music /
            ],
            [
                1, 0, 0, 'AnonymousCoward', 'Anonymous Coward',
                '', '', '', 0, '', '', '', '', '', ''
            ],
            [ 1, 0, 0, 'admin', 'Enoch Root', '', 'admin', '', 0, '', '', '', '', '', '' ],
        ]
    );

    my @prefs =
        $schema->populate( 'Preference',
        [ [qw/ prefkey prefvalue /], [ 'name', 'MojoMojo' ], [ 'admins', 'admin' ], ] );

    my @pages = $schema->populate(
        'Page',
        [
            [qw/ version parent name name_orig depth lft rgt content_version /],
            [ undef, undef, '/',     '/',     0, 1, 4, undef ],
            [ undef, 1,     'help',  'Help',  1, 2, 3, undef ],
            [ undef, 1,     'admin', 'Admin', 1, 2, 3, undef ],
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
                1, 1, $people[1]->id, 0, 'h1. Welcome to MojoMojo!

This is your front page. To start administrating your wiki, please log in with
username admin/password admin. At that point you will be able to set up your
configuration. If you want to play around a little with the wiki, just create
a NewPage or edit this one through the edit link at the bottom.

h2. Need some assistance?

Check out our [[Help]] section.', 'released', 1, 1, '', '', '', ''
            ],
            [
                2, 1, $people[1]->id, 0, 'h1. Help Index.

h2. Editing Pages
h2. Formatter Syntax.
h2. Using Tags
h2. Attachments & Photos', 'released', 1, 1, '', '', '', ''
            ],
            [
                3, 1, $people[1]->id, 0, 'h1. Admin User.

This is the default home for the admin user. You can change this text by pressing the _Edit_ link at the bottom.',
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

1;
