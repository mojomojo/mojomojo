package MojoMojo::M::Core::Revision;

use strict;
use base 'Catalyst::Base';
use Time::Piece;
use utf8;

__PACKAGE__->has_a(
    modified_date => 'Time::Piece',
    inflate => sub {
  Time::Piece->strptime( shift, "%Y-%m-%dT%H:%M:%S" );
    },
    deflate => 'datetime'
);

sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}

sub formatted_content {
    return MojoMojo::M::Core::Page::formatted_content(@_);
}

1;
