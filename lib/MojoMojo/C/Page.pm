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
  }, '!page/upload' => sub {
      my ( $self, $c, $node ) = @_;
      $c->forward('!page/view');
      $c->stash->{template} = 'page/upload.tt';
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
