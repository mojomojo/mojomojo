        package MojoMojo::C::Tag;

        use strict;
        use base 'Catalyst::Base';

        MojoMojo->action(

            '!tag/list' => sub {
                my ( $self, $c, $tag ) = @_;

                $c->stash->{template} = 'tag/list.tt';
                return unless $tag;

                $c->stash->{activetag} = $tag;
                $c->stash->{tags}   = [MojoMojo::M::Core::Tag->search_most_used] ;
                $c->stash->{pages} = [MojoMojo::M::Core::Page->search_by_tag($tag)];
                $c->stash->{related} = [MojoMojo::M::Core::Tag->related_to($tag)];
            },
            '!tag/recent' => sub {
                my ($self,$c,$tag) = @_;
                $c->stash->{template} = 'tag/recent.tt';
                return unless $tag;
                $c->stash->{activetag}   = $tag;
                $c->stash->{tags}   = [MojoMojo::M::Core::Tag->search_most_used] ;
                $c->stash->{pages} = [MojoMojo::M::Core::Page->search_by_tag_and_date($tag)];
    }
);
    
1;
