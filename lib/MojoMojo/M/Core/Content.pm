package MojoMojo::M::Core::Content;

use strict;
use base 'Catalyst::Base';
use Time::Piece;
use utf8;

__PACKAGE__->has_a(
    created => 'Time::Piece',
    inflate => sub {
	Time::Piece->strptime( shift, "%FT%H:%M:%S" );
    },
    deflate => 'datetime'
);

# this is in Page.pm now, but should probably go to Revision.pm ...
sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}

sub formatted {
    my ($self, $base, $content) = @_;
    $content ||= $self->utf8;
    MojoMojo->call_plugins("format_content", \$content, $base) if ($content);
    return $content;
}

sub utf8 {
    my $self    = shift;
    my $body = $self->body;
    utf8::decode($body);
    return $body;
    }

1;
