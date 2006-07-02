package # hide from PAUSE
    MojoMojoTestSchema;

use strict;
use warnings;
use MojoMojo::Schema;
use YAML;

=head1 NAME

MojoMojoTestSchema - Library to be used by DBIx::Class test scripts.

=head1 SYNOPSIS

  use lib qw(t/lib);
  use MojoMojoTestSchema;
  use Test::More;

  my $schema = MojoMojoTestSchema->init_schema();

=head1 DESCRIPTION

This module provides the basic utilities to write tests against
MojoMojo::Schema. Shamelessly stolen from DBICTest in the DBIx::Class test suite.

=head1 METHODS

=head2 init_schema

  my $schema = MojoMojoTestSchema->init_schema(
    no_deploy=>1,
    no_populate=>1,
  );

This method removes the test SQLite database in t/var/mojomojo.db
and then creates a new, empty database.

This method will call deploy_schema() by default, unless the
no_deploy flag is set.

Also, by default, this method will call populate_schema() by
default, unless the no_deploy or no_populate flags are set.

=cut

sub init_schema {
    my $self = shift;
    my %args = @_;

    my $db_dir = 't/var';
    my $db_file = "$db_dir/mojomojo.db";

    unlink($db_file) if -e $db_file;
    mkdir($db_dir) unless -d $db_dir;

    my $dsn = $ENV{"MOJOMOJO_TEST_SCHEMA_DSN"} || "dbi:SQLite:${db_file}";
    my $dbuser = $ENV{"MOJOMOJO_TEST_SCHEMA_DBUSER"} || '';
    my $dbpass = $ENV{"MOJOMOJO_TEST_SCHEMA_DBPASS"} || '';

    my $schema = MojoMojo::Schema->compose_connection('MojoMojoTestSchema' => $dsn, $dbuser, $dbpass);
    if ( !$args{no_deploy} ) {
        __PACKAGE__->deploy_schema( $schema );
        __PACKAGE__->populate_schema( $schema ) if( !$args{no_populate} );
    }
    my $config = {
	name => 'MojoMojo Test Suite',
	'Model::DBIC' => {
	    connect_info => [ $dsn ], 
	}
    };
    YAML::DumpFile('t/var/mojomojo.yml',$config);
    

    return $schema;
}

=head2 deploy_schema

  MojoMojoTestSchema->deploy_schema( $schema );

This method does one of two things to the schema.  It can either call
the experimental $schema->deploy() if the DBICTEST_SQLT_DEPLOY environment
variable is set, otherwise the default is to read in the db/sqlite/mojomojo.sql
file and execute the SQL within. Either way you end up with a fresh set
of tables for testing.

=cut

sub deploy_schema {
    my $self = shift;
    my $schema = shift;

    if ($ENV{"MOJOMOJO_TEST_SCHEMA_SQLT_DEPLOY"}) {
        return $schema->deploy();
    } else {
        open IN, "db/sqlite/mojomojo.sql";
        my $sql;
        { local $/ = undef; $sql = <IN>; }
        close IN;
        my $dbh = $schema->storage->dbh;
        map {
            $dbh->do($_) or die $dbh->errstr;
        } split(/;\s*\n/, $sql);
    }
}

=head2 populate_schema

  DBICTest->populate_schema( $schema );

After you deploy your schema you can use this method to populate
the tables with test data.

=cut

sub populate_schema {
    my $self = shift;
    my $schema = shift;

    $schema->storage->dbh->do("PRAGMA synchronous = OFF");

    $schema->populate('Artist', [
        [ qw/artistid name/ ],
        [ 1, 'Caterwauler McCrae' ],
        [ 2, 'Random Boy Band' ],
        [ 3, 'We Are Goth' ],
    ]);

    $schema->populate('CD', [
        [ qw/cdid artist title year/ ],
        [ 1, 1, "Spoonful of bees", 1999 ],
        [ 2, 1, "Forkful of bees", 2001 ],
        [ 3, 1, "Caterwaulin' Blues", 1997 ],
        [ 4, 2, "Generic Manufactured Singles", 2001 ],
        [ 5, 3, "Come Be Depressed With Us", 1998 ],
    ]);

    $schema->populate('LinerNotes', [
        [ qw/liner_id notes/ ],
        [ 2, "Buy Whiskey!" ],
        [ 4, "Buy Merch!" ],
        [ 5, "Kill Yourself!" ],
    ]);

    $schema->populate('Tag', [
        [ qw/tagid cd tag/ ],
        [ 1, 1, "Blue" ],
        [ 2, 2, "Blue" ],
        [ 3, 3, "Blue" ],
        [ 4, 5, "Blue" ],
        [ 5, 2, "Cheesy" ],
        [ 6, 4, "Cheesy" ],
        [ 7, 5, "Cheesy" ],
        [ 8, 2, "Shiny" ],
        [ 9, 4, "Shiny" ],
    ]);

    $schema->populate('TwoKeys', [
        [ qw/artist cd/ ],
        [ 1, 1 ],
        [ 1, 2 ],
        [ 2, 2 ],
    ]);

    $schema->populate('FourKeys', [
        [ qw/foo bar hello goodbye sensors/ ],
        [ 1, 2, 3, 4, 'online' ],
        [ 5, 4, 3, 6, 'offline' ],
    ]);

    $schema->populate('OneKey', [
        [ qw/id artist cd/ ],
        [ 1, 1, 1 ],
        [ 2, 1, 2 ],
        [ 3, 2, 2 ],
    ]);

    $schema->populate('SelfRef', [
        [ qw/id name/ ],
        [ 1, 'First' ],
        [ 2, 'Second' ],
    ]);

    $schema->populate('SelfRefAlias', [
        [ qw/self_ref alias/ ],


        [ 1, 2 ]
    ]);

    $schema->populate('ArtistUndirectedMap', [
        [ qw/id1 id2/ ],
        [ 1, 2 ]
    ]);

    $schema->populate('Producer', [
        [ qw/producerid name/ ],
        [ 1, 'Matt S Trout' ],
        [ 2, 'Bob The Builder' ],
        [ 3, 'Fred The Phenotype' ],
    ]);

    $schema->populate('CD_to_Producer', [
        [ qw/cd producer/ ],
        [ 1, 1 ],
        [ 1, 2 ],
        [ 1, 3 ],
    ]);

    $schema->populate('TreeLike', [
        [ qw/id parent name/ ],
        [ 1, 0, 'foo'  ],
        [ 2, 1, 'bar'  ],
        [ 3, 2, 'baz'  ],
        [ 4, 3, 'quux' ],
    ]);

    $schema->populate('Track', [
        [ qw/trackid cd  position title/ ],
        [ 4, 2, 1, "Stung with Success"],
        [ 5, 2, 2, "Stripy"],
        [ 6, 2, 3, "Sticky Honey"],
        [ 7, 3, 1, "Yowlin"],
        [ 8, 3, 2, "Howlin"],
        [ 9, 3, 3, "Fowlin"],
        [ 10, 4, 1, "Boring Name"],
        [ 11, 4, 2, "Boring Song"],
        [ 12, 4, 3, "No More Ideas"],
        [ 13, 5, 1, "Sad"],
        [ 14, 5, 2, "Under The Weather"],
        [ 15, 5, 3, "Suicidal"],
        [ 16, 1, 1, "The Bees Knees"],
        [ 17, 1, 2, "Apiary"],
        [ 18, 1, 3, "Beehind You"],
    ]);

    $schema->populate('Event', [
        [ qw/id starts_at created_on/ ],
        [ 1, '2006-04-25 22:24:33', '2006-06-22 21:00:05'],
    ]);

    $schema->populate('Link', [
        [ qw/id title/ ],
        [ 1, 'aaa' ]
    ]);

    $schema->populate('Bookmark', [
        [ qw/id link/ ],
        [ 1, 1 ]
    ]);
}

1;

