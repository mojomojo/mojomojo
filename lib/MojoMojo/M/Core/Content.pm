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
    return MojoMojo::M::Core::Revision::formatted_diff(@_);
}

sub formatted {
    my ( $self,$base, $content ) = @_;
    $content ||= $self->content_utf8;
    MojoMojo->call_plugins("format_content", \$content, $base) if ($content);
    return $content;
}


sub content_utf8 {
    my $self    = shift;
    my $content = $self->content;
    utf8::decode($content);
    return $content;
    }

1;
