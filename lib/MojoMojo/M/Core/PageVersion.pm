package MojoMojo::M::Core::PageVersion;

use strict;
use base 'Catalyst::Base';
use Time::Piece;
use utf8;

__PACKAGE__->has_a(
    remove_date => 'Time::Piece',
    inflate     => sub {
        Time::Piece->strptime( shift, "%Y-%m-%dT%H:%M:%S" );
    },
    deflate => 'datetime'
);

__PACKAGE__->has_a(
    release_date => 'Time::Piece',
    inflate      => sub {
        Time::Piece->strptime( shift, "%Y-%m-%dT%H:%M:%S" );
    },
    deflate => 'datetime'
);

# this should probably be re-defined here...
sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}

1;
