package MojoMojo::M::Core::Content;

use strict;
use base 'Catalyst::Base';
use Time::Piece;
use utf8;

__PACKAGE__->has_a(
    modified_date => 'Time::Piece',
    inflate => sub {
	Time::Piece->strptime( shift, "%FT%H:%M:%S" );
    },
    deflate => 'datetime'
);

sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}

sub formatted_content {
    return MojoMojo::M::Core::Page::formatted_content(@_);
}

sub content_utf8 {
    my $self    = shift;
    my $content = $self->content;
    utf8::decode($content);
    return $content;
    }

1;
