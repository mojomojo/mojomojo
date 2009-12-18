package # hide from PAUSE
    MojoMojoTestSchema;

use strict;
use warnings;
use MojoMojo::Schema;
use YAML;

my $attrs = {
    # starting with v3.3, SQLite supports the "IF EXISTS" clause to "DROP TABLE",
    # even though SQL::Translator::Producer::SQLite 1.59 isn't passed along this option
    # see https://rt.cpan.org/Ticket/Display.html?id=48688
    sqlite_version => 3.3,
    add_drop_table => 1,
    no_comments => 1
};
my $db_dir = 't/var';
my $db_file = "$db_dir/mojomojo.db";


=head1 NAME

MojoMojoTestSchema - Library to be used by DBIx::Class test scripts.

=head1 SYNOPSIS

    use lib qw(t/lib);
    use MojoMojoTestSchema;
    use Test::More;

    my $schema = MojoMojoTestSchema->init_schema();

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
L<MojoMojo::Schema>. Shamelessly stolen from DBICTest in the
L<DBIx::Class> test suite.

=head1 METHODS

=head2 get_schema

Get a connection to the schema, without initializing it.

=cut

sub get_schema {
    my $dsn    = $ENV{"MOJOMOJO_TEST_SCHEMA_DSN"} || "dbi:SQLite:${db_file}";
    my $dbuser = $ENV{"MOJOMOJO_TEST_SCHEMA_DBUSER"} || '';
    my $dbpass = $ENV{"MOJOMOJO_TEST_SCHEMA_DBPASS"} || '';

    return MojoMojo::Schema->connect($dsn, $dbuser, $dbpass);
}

=head2 init_schema

    my $schema = MojoMojoTestSchema->init_schema(
        populate => 1,
    );

This method creates a fresh test database. If the C<populate> flag is true,
it will call L</populate_schema>. By default, a SQLite database is used,
in F<t/var/mojomojo.db>, but you can override that by exporting these
environment variables:

    MOJOMOJO_TEST_SCHEMA_DSN
    MOJOMOJO_TEST_SCHEMA_DBUSER
    MOJOMOJO_TEST_SCHEMA_DBPASS

The method also creates a MojoMojo config file in F<t/var/mojomojo.yml>.

=cut

sub init_schema {
    my $self = shift;
    my %args = @_;

    my $schema = $self->get_schema;

    # clear the database
    if (not $ENV{"MOJOMOJO_TEST_SCHEMA_DSN"}) {
        # Deleting the underlying files is faster than dropping tables, but for the
        # general case, we need to drop tables anyway, if $ENV{"MOJOMOJO_TEST_SCHEMA_DSN"}
        # was set to some other database.
        #unlink($db_file) if -e $db_file;
        #mkdir($db_dir) if not -d $db_dir;
    }
    # if add_drop_table has been specified, it will try to drop tables beforehand, but not "IF EXISTS",
    # due to a BUG in SQL::Translator: https://rt.cpan.org/Ticket/Display.html?id=48688
    # This will cause failures if the tables don't exist (i.e. when you first deploy):
    #     ("DBI Exception: DBD::$driver::db do failed: no such table")
    #
    #-mxh This is fragile because it relies on fixed output in the regex.
    #     Recently, the output changed to include a "\n" and broke this code.
    #     I added the s (and i) regex modifiers, but it still needs a better implementation.
    local $SIG{__WARN__} = sub {
        die @_ unless $_[0] =~ /no such table.*DROP TABLE/is;
    };
    $schema->deploy( $attrs );

    $self->populate_schema($schema) if $args{populate};

    my $config = {
        name => 'MojoMojo Test Suite',
        'Model::DBIC' => {
            connect_info => $schema->storage->connect_info,
        },
        attachment_dir => '__path_to(t/var/uploads)__',
        allowed => {
           src => [qw(youtube.com youporn.org iusethis.com)] ,
        },
        'View::Email' => { sender => { mailer => 'Test' } },
    };
    YAML::DumpFile('t/var/mojomojo.yml', $config);


    return $schema;
}

=head2 populate_schema

    MojoMojoTestSchema->populate_schema( $schema );

After deploying the schema, we can use this method to populate
the tables with test data: the MojoMojo welcome page, and test
permissions.

=cut

sub populate_schema {
    my $self = shift;
    my $schema = shift;

    $schema->storage->dbh->do("PRAGMA synchronous = OFF");

    $schema->storage->ensure_connected;

    $schema->create_initial_data;
    $self->create_test_data($schema);
}

=head2 create_test_data

Populate the schema with some test data. For now, path permissions.

=cut

sub create_test_data {
    my ($self, $schema)=@_;
    my @roles = $schema->resultset('Role')->search();
    $schema->populate('PathPermissions',
        [
            [ qw/path role apply_to_subpages create_allowed delete_allowed edit_allowed view_allowed attachment_allowed / ],
            [ '/admin', $roles[0]->id, qw/ no yes yes yes yes yes yes/ ],
            [ '/admin', $roles[0]->id, qw/ yes yes yes yes yes yes yes/ ],
            [ '/help', $roles[0]->id, qw/no yes yes yes yes yes yes/ ],
            [ '/help', $roles[0]->id, qw/ yes yes yes yes yes yes yes/ ],
        ]
    )
}

1;
