package MojoMojo::Schema::Result::Person;

use strict;
use warnings;

use Digest::SHA1;

use parent qw/MojoMojo::Schema::Base::Result/;

use Text::Textile;
my $textile = Text::Textile->new( flavor => "xhtml1", charset => 'utf-8' );

__PACKAGE__->load_components(
    qw/DateTime::Epoch TimeStamp EncodedColumn Core/);
__PACKAGE__->table("person");
__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "INTEGER",
        is_nullable       => 0,
        size              => undef,
        is_auto_increment => 1
    },
    
    "active",
    # -1 = user registered but hasn't confirmed e-mail address yet;
    # 0 = manually set to inactive from Site Settings -> Users;
    # 1 = active user
    {
        data_type     => "INTEGER",
        is_nullable   => 0,
        default_value => -1,
        size          => undef
    },
    
    "registered",

#   { data_type => "BIGINT", is_nullable => 0, size => undef, epoch => 'ctime' },
    {
        data_type        => "BIGINT",
        is_nullable      => 0,
        size             => undef,
        inflate_datetime => 'epoch',
        set_on_create    => 1,
    },
    "views",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "photo",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "login",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "name",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "email",
    { data_type => "VARCHAR", is_nullable => 0, size => 100 },
    "pass",
    {
        data_type           => "CHAR",
        is_nullable         => 0,
        size                => 40,
        encode_column       => 1,
        encode_class        => 'Digest',
        encode_args         => { algorithm => 'SHA-1', format => 'hex' },
        encode_check_method => 'check_password',
    },
    "timezone",
    { data_type => "VARCHAR", is_nullable => 1, size => 100 },
    "born",
    {
        data_type                 => "BIGINT",
        is_nullable               => 1,
        size                      => undef,
        default_value             => undef,
        # epoch => 1,
        inflate_datetime          => 'epoch',
        datetime_undef_if_invalid => 1,
    },
    "gender",
    { data_type => "CHAR", is_nullable => 1, size => 1 },
    "occupation",
    { data_type => "VARCHAR", is_nullable => 1, size => 100 },
    "industry",
    { data_type => "VARCHAR", is_nullable => 1, size => 100 },
    "interests",
    { data_type => "TEXT", is_nullable => 1, size => undef },
    "movies",
    { data_type => "TEXT", is_nullable => 1, size => undef },
    "music",
    { data_type => "TEXT", is_nullable => 1, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint( login => [qw/login/], );
__PACKAGE__->add_unique_constraint( email => [qw/email/], );
__PACKAGE__->has_many(
    "entries",
    "MojoMojo::Schema::Result::Entry",
    { "foreign.author" => "self.id" }
);
__PACKAGE__->has_many(
    "tags",
    "MojoMojo::Schema::Result::Tag",
    { "foreign.person" => "self.id" }
);
__PACKAGE__->has_many(
    "comments",
    "MojoMojo::Schema::Result::Comment",
    { "foreign.poster" => "self.id" }
);
__PACKAGE__->has_many(
    "role_members",
    "MojoMojo::Schema::Result::RoleMember",
    { "foreign.person" => "self.id" },
);
__PACKAGE__->has_many(
    "page_versions",
    "MojoMojo::Schema::Result::PageVersion",
    { "foreign.creator" => "self.id" },
);
__PACKAGE__->many_to_many( roles => 'role_members', 'role' );
__PACKAGE__->has_many(
    "contents",
    "MojoMojo::Schema::Result::Content",
    { "foreign.creator" => "self.id" }
);

=head1 NAME

MojoMojo::Schema::Result::Person - store user info

=head1 METHODS

=head2 is_admin

Checks if user belongs to list of admins.

=cut

sub is_admin {
    my $self   = shift;
    my $admins = MojoMojo->pref('admins');
    my $login  = $self->login;
    return 1 if $login && $admins =~ m/\b$login\b/;
    return 0;
}

=head2 link

Returns a relative link to the user's home node.

=cut

sub link {
    my ($self) = @_;
    return lc "/" . ( $self->login || MojoMojo->pref('anonymous_user') );
}

=head2 can_edit <path>

Checks if a user has rights to edit a given path.

=cut

sub can_edit {
    my ( $self, $page ) = @_;
    return 0 unless $self->active;

    # allow admins
    return 1 if $self->is_admin;

    # allow edit unless users are restricted to home page
    return 1 unless MojoMojo->pref('restricted_user');

    # allow users editing their pages
    my $link = $self->link;
    return 1 if $page =~ m|^$link\b|i;
    return 0;
}

=head2 pages

Return the pages created by the user.

=cut

sub pages {
    my ($self) = @_;
    my @pages =
      $self->result_source->related_source('page_versions')
      ->related_source('page')->resultset->search(
        { 'versions.creator' => $self->id, },
        {
            join     => [qw/versions/],
            order_by => ['me.name'],
            distinct => 1,
        }
      )->all;
    return $self->result_source->related_source('page_versions')
      ->related_source('page')->resultset->set_paths(@pages);
}

=head2 pass_matches <pass1> <pass2>

Returns true if pass1 eq pass2.

=cut

sub pass_matches {
    return 1 if ( $_[0] eq $_[1] );
    return 0;
}

=head2 valid_pass <password>

Check password against database.

=cut

sub valid_pass {
    my ( $self, $pass ) = @_;
    return $self->check_password($pass);
}

=head2 hashed

Apply a SHA1 hash to the input string.

=cut

sub hashed {
    my ( $self, $secret ) = @_;
    return Digest::SHA1::sha1_hex( $self->id . $secret );
}

# FIXME: the formatter is arbitrarily taken to be Textile; it could be MultiMarkdown
# http://github.com/marcusramberg/mojomojo/issues/#issue/29

=head2 interests_formatted

Format a person's interests.

=cut

sub interests_formatted { $textile->process( shift->interests ); }

=head2 music_formatted

Format a person's music preferences.

=cut
sub music_formatted     { $textile->process( shift->music ); }

=head2 movies_formatted

Format a person's movie tastes.

=cut

sub movies_formatted    { $textile->process( shift->movies ); }

=head2 age

Returns age of the user in years.

=cut

sub age {
    my ($self) = @_;
    if ( my $birthdate = $self->born ) {
        my $diff = DateTime->now - $birthdate;
        return $diff->years;
    }
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
