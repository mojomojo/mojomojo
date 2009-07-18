package MojoMojo::Schema::Result::Comment;

use strict;
use warnings;

use parent qw/MojoMojo::Schema::Base::Result/;

use Text::Textile;
my $textile = Text::Textile->new(
    disable_html  => 1,
    flavor        => 'xhtml2',
    charset       => 'utf8',
    char_encoding => 1
);

__PACKAGE__->load_components(
    qw/DateTime::Epoch TimeStamp UTF8Columns Core/);
__PACKAGE__->table("comment");
__PACKAGE__->add_columns(
    "id",
    {
        data_type         => "INTEGER",
        is_nullable       => 0,
        size              => undef,
        is_auto_increment => 1
    },
    "poster",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "picture",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "posted",
    {
        data_type        => "BIGINT",
        is_nullable      => 0,
        size             => undef,
        inflate_datetime => 'epoch',
        set_on_create    => 1,
    },
    "body",
    { data_type => "TEXT", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to(
    "poster",
    "MojoMojo::Schema::Result::Person",
    { id => "poster" }
);
__PACKAGE__->belongs_to(
    "page",
    "MojoMojo::Schema::Result::Page",
    { id => "page" }
);
__PACKAGE__->belongs_to(
    "picture",
    "MojoMojo::Schema::Result::Photo",
    { id => "picture" }
);
__PACKAGE__->utf8_columns(qw/body/);

=head1 NAME

MojoMojo::Schema::Result::Comment

=head1 METHODS

=over 4

=item formatted

Returns a textile formatted version of the given comment.

=cut

sub formatted {
    my $self = shift;
    return $textile->process( $self->body );
}

1;
