package MojoMojo::C::Page;

use strict;
use base 'Catalyst::Base';
use IO::Scalar;
use URI;
use Time::Piece;
use File::MimeInfo::Magic;
my $class = 'MojoMojo::M::Core::Page';

#For uploads
$CGI::Simple::POST_MAX = 1048576000;

=head1 NAME

MojoMojo::C::Page - Page controller

=head1 SYNOPSIS

=head1 DESCRIPTION

This controller is the main juice of MojoMojo. it handles all the
actions related to wiki pages. actions are redispatched to this
controller based on a Regex controller in the main MojoMojo class.

every private action here expects to have a node in args. They
can be called with urls like /MyNode.action .


=head1 ACTIONS

=over 4

=item  view

This is probably the most common action in MojoMojo. A lot of the 
other actions redispatches to this one. It will prepare the stash 
for page view, and set the template to view.tt, unless another is 
already set.

It also takes an optional 'rev' parameter, in which case it will
load the provided revision instead.

=cut

sub view : Private {
    my ( $self, $c, $node ) = @_;

    $c->stash->{template} ||= 'page/view.tt';

    $node ||= $c->pref('home_node');
    my $page = MojoMojo::M::Core::Page->get_page( $node );
    return $c->forward('edit') unless $page && $page->revision;

    $c->form( optional => ['rev'] );
    if ( my $rev = $c->form->valid('rev') ) {
      $c->stash->{rev} = $page->get_revision($rev);
        $c->stash->{template} = 'norevision.tt' unless
            $c->stash->{rev};
      }
      $c->stash->{page} =  $page;
}

=item edit

This action will display the edit form, then save the previous
revision, and create a new based on the posted content.
after saving, it will forward to the highlight action.

=cut

sub edit : Private {
      my ( $self, $c, $node ) = @_;

      $c->stash->{template} = 'page/edit.tt';
      $c->forward('/user/login') if $c->req->params->{login} && 
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

}

=item print

this action is the same as the view action, with another template

=cut

sub print : Private {
      my ( $self, $c, $node ) = @_;
      $c->stash->{template} = 'page/print.tt';
      $c->forward('view');
}

sub  attachments : Private {
      my ( $self, $c, $node ) = @_;
      $c->forward('view');
      $c->stash->{template} = 'page/attachments.tt';
      my $page=$c->stash->{page};
      if (my $file=$c->req->params->{file}) {
          my $att=MojoMojo::M::Core::Attachment->create
                  ({name=>$file,page=>$page});
            
          my $fh = $c->req->uploads->{$file}->{fh};
          my $filename=$c->home."/uploads/".$att->id; 
          open(NEW_FILE, ">$filename") or
                  die "Can't open $filename for writing: $!";
          while ($fh->read(my $buf, 32768)) {
              print NEW_FILE $buf;
          }
          close NEW_FILE;
          $att->contenttype(mimetype($filename));
          $att->size(-s $filename);
          $att->update();
      }
}  
sub tags : Private {
      my ( $self, $c, $node ) = @_;
      $node=$class->get_page($node) unless ref $node;
      $c->stash->{template} = 'page/tags.tt';
      my @tags = $node->others_tags($c->req->{user_id});
      $c->stash->{others_tags} = [@tags];
      @tags =$node->user_tags($c->req->{user_id});
      $c->stash->{taglist} = ' '.join(' ',map {$_->tag} @tags).' ' ;
      $c->stash->{tags} =  [@tags];
} 
sub list : Path('/.list') {
      my ( $self, $c, $tag ) = @_;
      return $c->forward('/tag/list') if $tag;
      $c->stash->{template} = 'page/list.tt';
      $c->stash->{pages} = [ $class->retrieve_all_sorted_by('node') ];
      # FIXME - real data here please
    $c->stash->{orphans} = [ ];
    $c->stash->{wanted} = [ ];
    $c->stash->{tags} = [ MojoMojo::M::Core::Tag->search_most_used() ];
}
   
sub recent : Path('/.recent') {
  my ( $self, $c, $tag ) = @_;
  return $c->forward('/tag/recent') if $tag;
  $c->stash->{template} = 'page/recent.tt';
  $c->stash->{tags}   = [MojoMojo::M::Core::Tag->search_most_used];
  $c->stash->{pages}  = [MojoMojo::M::Core::Page->search_recent];
  # FIXME - needs to be populated even without tags
}

=item print

this action is the same as the view action, with another template

=cut

sub rss : Private {
  my ( $self, $c, $node ) = @_;
  $c->stash->{template} = 'page/rss.tt';
  $c->forward('view');
}

sub atom : Private {
   my ( $self, $c, $node ) = @_;
   $c->stash->{template} = 'page/atom.tt';
   $c->forward('view');
} 

sub rss_full : Private  {
   my ( $self, $c, $node ) = @_;
   $c->stash->{template} = 'page/rss_full.tt';
   $c->forward('view');
}

sub highlight : Private {
   my ( $self, $c, $node ) = @_;
   $c->stash->{template} = 'page/highlight.tt';
   $c->forward('view');
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify
it under the same terms as perl itself.

=cut

1;
