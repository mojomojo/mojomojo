package MojoMojo::C::Gallery;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::Gallery - Catalyst component

=head1 SYNOPSIS

See L<MojoMojo>

=head1 DESCRIPTION

Catalyst component.

=head1 METHODS

=over 4

=item default

=cut

sub default : Private {
    my ( $self, $c, $action, $page) = @_;
    $c->stash->{template} = 'gallery.tt';
    # oops, we have a column value named Page
    # FIXME : Messing with the iterator.
    my ($pager,$iterator) =MojoMojo::M::Core::Photo->pager( 
        'attachment.page'=>$c->stash->{page}, {
            page           =>$page || 1,
            rows             => 12,
            order_by => 'taken'
        });
    $c->stash->{pictures} = $iterator;
    $c->stash->{pager} = $pager;
}

sub by_tag : Local {
    my ( $self, $c, $tag,$page) = @_;
    $tag=MojoMojo::M::Core::Tag->search(tag=>$tag)->next;
    $c->stash->{template} = 'gallery.tt';
    $c->stash->{tag} = $tag->tag;
    my $conditions = { 'tags.tag' => $tag->tag };
    $$conditions{'attachment.page'} = [ 
          map { $_->id  } ($c->stash->{page}->descendants,
                           $c->stash->{page}) ] 
     unless length($c->stash->{page}->path) == 1;  # root
    my ($pager,$iterator) =MojoMojo::M::Core::Photo->pager( 
        $conditions, { 
            page     => $page || 1,
            rows     => 12,
            order_by => 'taken DESC'
        });
    $c->stash->{pictures} = $iterator;
    $c->stash->{pager} = $pager;
}

sub p : Global {
    my ($self,$c,$photo)  = @_;
    $photo                = MojoMojo::M::Core::Photo->retrieve($photo);
    $c->stash->{photo}    = $photo;
    $c->forward('tags');
    $c->stash->{template} = 'gallery/photo.tt';
    $c->stash->{next}     = $photo->retrieve_next({
        'attachment.page'=>$c->stash->{page}, 
        },{order_by=>'taken'});
    $c->stash->{prev}     = $photo->retrieve_previous({
        'attachment.page'=>$c->stash->{page}, 
        },{order_by=>'taken'});
    
}

sub p_by_tag : Global {
    my ( $self, $c, $tag, $photo ) = @_;
    $photo                = MojoMojo::M::Core::Photo->retrieve($photo);
    $c->stash->{photo}    = $photo;
    $c->stash->{tag}      = $tag; 
    $c->forward('tags');
    $c->stash->{template} = 'gallery/photo.tt';
    $c->stash->{next}     = $photo->next_by_tag($tag);
    $c->stash->{prev}     = $photo->prev_by_tag($tag);
}

=item submittag (/gallery/submittag)

Add a tag through form submit

=cut

sub submittag : Local {
    my ( $self, $c, $photo ) = @_;
    $c->req->args( [ $photo,$c->req->params->{tag} ] );
    $c->forward('tag');
}

=item tag (/.jsrpc/tag)

add a tag to a page. return list of yours and popular tags.

=cut

sub tag : Local {
    my ( $self, $c,$photo, $tagname ) = @_;
    ($tagname)= $tagname =~ m/(\w+)/;
    unless (
        ! $tagname ||
        MojoMojo::M::Core::Tag->search(
            photo   => $photo,
            person => $c->stash->{user},
            tag    => $tagname
        )->next()
      ) {
        MojoMojo::M::Core::Tag->create(
            {
                photo  => $photo,
                tag    => $tagname,
                person => $c->stash->{user}
            }
          )
          if $photo;
    }
    $c->stash->{photo}=$photo;
    $c->req->args( [ $tagname ] );
    $c->forward('tags');
}

=item untag (/.jsrpc/untag)

remove a tag to a page. return list of yours and popular tags.

=cut

sub untag : Local {
    my ( $self, $c, $photo, $tagname ) = @_;
    my $tag = MojoMojo::M::Core::Tag->search(
        photo   => $photo,
        person => $c->stash->{user},
        tag    => $tagname
    )->next();
    $tag->delete() if $tag;
    $c->stash->{photo}=$photo;
    $c->req->args( [ $tagname ] );
    $c->forward('tags');
}


sub tags : Local {
    my ( $self, $c, $highlight ) = @_;
    $c->stash->{template}  = 'gallery/tags.tt';
    $c->stash->{highlight} = $highlight;
    my $photo=$c->stash->{photo}||$c->req->params->{photo};
    $c->log->info('photo is '.$photo);
    $photo=MojoMojo::M::Core::Photo->retrieve($photo) unless ref $photo;
    $c->stash->{photo}=$photo;
    $c->log->info('user is '.$c->req->{user_id});
    if ($c->req->{user}) {
    my @tags = $photo->others_tags( $c->req->{user_id});
    $c->stash->{others_tags} = [@tags];
    @tags                    = $photo->user_tags( $c->stash->{user} );
    $c->stash->{taglist}     = ' ' . join( ' ', map { $_->tag } @tags ) . ' ';
    $c->stash->{tags}        = [@tags];
    } else {
      $c->stash->{others_tags}      = [ $photo->tags ];
    }
}

sub description : Local { 
    my ( $self, $c, $photo ) = @_;
    $c->form(required=>[qw/description/]);
    my $img=MojoMojo::M::Core::Photo->retrieve($photo);
    unless ($c->form->has_missing && $c->form->has_invalid ) {
      $img->update_from_form($c->form);
    }
      $c->res->body('<em>updated ok</em>');
}

sub title : Local { 
    my ( $self, $c, $photo ) = @_;
    $c->form(required=>[qw/title/]);
    my $img=MojoMojo::M::Core::Photo->retrieve($photo);
    unless ($c->form->has_missing && $c->form->has_invalid ) {
      $img->update_from_form($c->form);
    }
      $c->res->body('<em>updated ok</em>');
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify 
it under the same terms as perl itself.

=cut

1;
