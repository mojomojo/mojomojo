package MojoMojo::C::Tag;

use strict;
use base 'Catalyst::Base';

MojoMojo->action(

    '?list' => sub {
        my ( $self, $c, $tag ) = @_;
	
	$c->stash->{template} = 'tag/list.tt';

	return unless $tag;
	$c->stash->{tag} = $tag;
	$c->stash->{pages} = MojoMojo::M::CDBI::Page->search_by_tag($tag);
	$c->stash->{related} = MojoMojo::M::CDBI::Tag->related_to($tag)
    },
    '?recent' => sub {
        my ($self,$c,$tag) = @_;
	$c->stash->{template} = 'tag/recent.tt';
	return unless $tag;
	$c->stash->{tag}   = $tag;
	$c->stash->{pages} = MojoMojo::M::CDBI::Page->search_by_tag_and_date($tag);
	$c->stash->{related} = MojoMojo::M::CDBI::Tag->related_to($tag)
    }
);
    
1;
