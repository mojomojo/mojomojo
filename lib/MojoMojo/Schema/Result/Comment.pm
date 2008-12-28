package MojoMojo::Schema::Result::Comment;

use strict;
use warnings;

use base qw/MojoMojo::Schema::Base::Result/;

use Text::Textile2();
my $textile = Text::Textile2->new(
    disable_html  => 1,
    flavor        => 'xhtml2',
    charset       => 'utf8',
    char_encoding => 1
);

__PACKAGE__->load_components(qw/DateTime::Epoch PK::Auto UTF8Columns Core/);
__PACKAGE__->table("comment");
__PACKAGE__->add_columns(
    "id",
    "id",
    { data_type => "INTEGER", is_nullable => 0, size => undef, is_auto_increment => 1 },
    "poster",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "page",
    { data_type => "INTEGER", is_nullable => 0, size => undef },
    "picture",
    { data_type => "INTEGER", is_nullable => 1, size => undef },
    "posted",
    { data_type => "BIGINT", is_nullable => 0, size => undef, epoch => 'ctime' },
    "body",
    { data_type => "TEXT", is_nullable => 0, size => undef },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to( "poster",  "Person", { id => "poster" } );
__PACKAGE__->belongs_to( "page",    "Page",   { id => "page" } );
__PACKAGE__->belongs_to( "picture", "Photo",  { id => "picture" } );
__PACKAGE__->utf8_columns(qw/body/);

=item formatted

Returns a textile formatted version of the given comment.

=cut

sub formatted {
    my $self = shift;
    return $textile->process( $self->body );
}

1;
