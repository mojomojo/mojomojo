package MojoMojo::M::Core::Revision;

use strict;
use base 'Catalyst::Base';

__PACKAGE__->columns( TEMP => 'content_utf8' );
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
    inflate => sub {
	Time::Piece->strptime( shift, "%FT%H:%M:%S" );
    },
    deflate => 'datetime'
);

sub archive {
    my ( $self, $page ) = @_;
    $self->create(
	{
	    page    => $page->id,
	    content => $page->content,
	    updated => $page->updated,
	    user    => $page->user
	}
    );
}

sub formatted_diff {
    return MojoMojo::M::Core::Page::formatted_diff(@_);
}

sub formatted_content {
    return MojoMojo::M::Core::Page::formatted_content(@_);
}
sub node      { shift->page->node; }

1;
