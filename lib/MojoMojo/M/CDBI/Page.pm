package MojoMojo::M::CDBI::Page;

use strict;
use Time::Piece;

__PACKAGE__->columns( Essential => qw/user node updated/ );
__PACKAGE__->columns( TEMP      => 'content_utf8' );
__PACKAGE__->add_trigger(
    select => sub {
        my $self    = shift;
        my $content = $self->content;
        utf8::decode($content);
        $self->content_utf8($content);
    }
);
__PACKAGE__->has_a(
    updated => 'Time::Piece',
    inflate => sub { Time::Piece->strptime( shift, "%FT%H:%M:%S" ) },
    deflate => 'datetime'
);
__PACKAGE__->has_many(
    links_to => [ 'MojoMojo::M::CDBI::Link' => 'from_page' ],
    "to_page"
);
__PACKAGE__->has_many(
    links_from => [ 'MojoMojo::M::CDBI::Link' => 'to_page' ],
    "from_page"
);

1;
