package MojoMojo::C::Page;

use strict;
use base 'Catalyst::Base';
use Algorithm::Diff;
use Archive::Zip;
use IO::Scalar;
use URI;
use Time::Piece;
my $class = 'MojoMojo::M::Core::Page';

MojoMojo->action(
  '!page/view' => sub {
    my ( $self, $c, $node ) = @_;

    $c->stash->{template} ||= 'page/view.tt';


    $node ||= $c->pref('home_node');
    my $page = MojoMojo::M::Core::Page->get_page( $node );
    return $c->forward('!page/edit') unless $page;

    $c->form( optional => ['rev'] );
    if ( my $rev = $c->form->valid('rev') ) {
      $c->stash->{rev} = abs $rev;

      my @revs = $page->revisions;
      if ( scalar @revs >= $rev ) {
        $c->stash->{page} =  $revs[ $rev - 1 ];
        $c->stash->{rev} = $rev;
      } else { 
        $c->stash->{template} = 'norevision.tt';
      }
    } else {
      $c->stash->{rev} = 0;
      $c->stash->{page} =  $page;
    }
  }, '!page/edit' => sub {
    my ( $self, $c, $node ) = @_;

    $c->stash->{template} = 'page/edit.tt';
    $c->forward('.login') if $c->req->params->{login} && 
                             ! $c->req->{user};

    my $editor = $c->req->{user_id} || 0;

    my $page   = $class->get_page( $node );
    unless ($page) {
      $c->form( optional => [qw/read write admin/],
                defaults => { owner=>$editor,
                              node=>$node});
      $page=$class->create_from_form( $c->form );
    }

    $c->form(required => [qw/content/],
             defaults=> { page=>$page,
                         updated=>localtime->datetime,
                         user=>$editor,
                         previous=>$page->revision});
    if ( $c->form->has_missing || $c->form->has_invalid ) {
      $c->stash->{page}=$page;
      return;
    }
    my $rev = MojoMojo::M::Core::Revision->create_from_form(
              $c->form );
    $page->revision($rev);
    $page->update;
    $c->req->args([$page]);
    $c->res->redirect($c->req->base.$node);

  }, '!page/print' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/print.tt';
      $c->forward('!page/view');
  }, '!page/rss' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/rss.tt';
      $c->forward('!page/view');
  }, '!page/atom' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/atom.tt';
      $c->forward('!page/view');
  }, '!page/rss' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/rss_full.tt';
      $c->forward('!page/view');
  } , '!page/tags' => sub {
      my ( $self, $c, $node ) = @_;
      $node=$class->get_page($node) unless ref $node;
      $c->stash->{template} = 'page/tags.tt';
      $c->stash->{tags} = $node->others_tags($c->req->{user_id});
      $c->stash->{my_tags} = $node->user_tags($c->req->{user_id});
  });

1;
