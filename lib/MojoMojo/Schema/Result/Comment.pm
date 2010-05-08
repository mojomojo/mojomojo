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
    qw/DateTime::Epoch TimeStamp Core/);
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

=head1 NAME

MojoMojo::Schema::Result::Comment - store comments

=head1 METHODS

=head2 formatted

Returns a Textile formatted version of the given comment.

TODO: the default formatter may not be Textile.

=cut

sub formatted {
    my $self = shift;
    return $textile->process( $self->body );
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
