package MojoMojo::C::Page;

use strict;
use base 'Catalyst::Base';
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
    return $c->forward('!page/edit') unless $page && $page->revision;

    $c->form( optional => ['rev'] );
    if ( my $rev = $c->form->valid('rev') ) {
      $c->stash->{rev} = $page->get_revision($rev);
        $c->stash->{template} = 'norevision.tt' unless
            $c->stash->{rev};
      }
      $c->stash->{page} =  $page;
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
                            previous=>$page->revision,
                            revnum=>($page->revision ?
                                     $page->revision->revnum+1 :
                                     1)
                            }
              );
      if ( $c->form->has_missing || $c->form->has_invalid ) {
          $c->stash->{page}=$page;
          return;
      }
      my $rev = MojoMojo::M::Core::Revision->create_from_form(
                $c->form );
      $page->revision($rev);
      $page->update;
      $c->res->redirect($c->req->base.$node.'.highlight');

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
  }, '!page/rss_full' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/rss_full.tt';
      $c->forward('!page/view');
  }, '!page/highlight' => sub {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/highlight.tt';
      $c->forward('!page/view');
  } , '!page/tags' => sub {
      my ( $self, $c, $node ) = @_;
      $node=$class->get_page($node) unless ref $node;
      $c->stash->{template} = 'page/tags.tt';
      my @tags = $node->others_tags($c->req->{user_id});
      $c->stash->{others_tags} = [@tags];
      @tags =$node->user_tags($c->req->{user_id});
      $c->stash->{taglist} = ' '.join(' ',map {$_->tag} @tags).' ' ;
      $c->stash->{tags} =  [@tags];
   }, '.list' => sub {
      my ( $self, $c, $tag ) = @_;
      return $c->forward('!tag/list') if $tag;
      $c->stash->{template} = 'page/list.tt';
      $c->stash->{pages} = [ $class->retrieve_all_sorted_by('node') ];
      # FIXME - real data here please
      $c->stash->{orphans} = [ ];
      $c->stash->{wanted} = [ ];
      $c->stash->{tags} = [ MojoMojo::M::Core::Tag->search_most_used() ];
   
   }, '.recent' => sub {
      my ( $self, $c, $tag ) = @_;
      return $c->forward('!tag/recent') if $tag;
      $c->stash->{template} = 'page/recent.tt';
      $c->stash->{tags}   = [MojoMojo::M::Core::Tag->search_most_used];
	    $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
      # FIXME - needs to be populated even without tags
   });

1;
