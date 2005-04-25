package MojoMojo::C::Page;

use strict;
use base 'Catalyst::Base';
use IO::Scalar;
use URI;
use Time::Piece;
use File::MimeInfo::Magic;
my $m_base = 'MojoMojo::M::Core::';
my $m_page_class = $m_base . 'Page';
my $m_rev_class = $m_base . 'Revision';

#For uploads
$CGI::Simple::POST_MAX = 1048576000;

=head1 NAME

MojoMojo::C::Page - Page controller

=head1 SYNOPSIS

=head1 DESCRIPTION

This controller is the main juice of MojoMojo. it handles all the
actions related to wiki pages. actions are redispatched to this
controller based on a Regex controller in the main MojoMojo class.

Every private action here expects to have a page path in args. They
can be called with urls like "/page1/page2.action".

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
    my ( $self, $c, $path ) = @_;

    my $stash = $c->stash;
    $stash->{template} ||= 'page/view.tt';

    my ($path_pages, $proto_pages) = @$stash{qw/ path_pages proto_pages /};
    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages)
    {
        ($path_pages, $proto_pages) = $m_page_class->path_pages( $path );
        @$stash{qw/ path_pages proto_pages /} = ($path_pages, $proto_pages);
    }
    # WARNING! there may be potential for an infinite loop here,
    # bouncing back and forth between "edit" and "view"
    return $c->forward('edit') if @$proto_pages;

    my $depth = @$path_pages - 1;
    $stash->{page} = $path_pages->[$depth];

    # revisions not "fixed" yet, revisit later
#     $c->form( optional => ['rev'] );
#     if ( my $rev = $c->form->valid('rev') ) {
#       $c->stash->{rev} = $page->get_revision($rev);
#       $c->stash->{template} = 'norevision.tt' unless
#       $c->stash->{rev};
#     }

}

=item edit

This action will display the edit form, then save the previous
revision, and create a new based on the posted content.
after saving, it will forward to the highlight action.

=cut

sub edit : Private {
    my ( $self, $c, $path ) = @_;

    my $stash = $c->stash;
    $stash->{template} = 'page/edit.tt';
    $c->forward('/user/login') if $c->req->params->{login} &&
                             ! $c->req->{user};

    my $user = $c->req->{user_id} || 0;

## scenarios

# * In all of these scenarios, we will have full path from the
# request url!!! Do we need to worry about it?

# * We may want to re-check the path anyway, so maybe this is a moot point...

# 1. user forwarded from view (or some other action) because page doesn't exist
#    - will already have searched for page in this case, which
#      we can put in stash and/or session
#    - * this is the only scenario in which we will have already gotten
#       path on server side

# 2. user submitted form with missing data
#    - we should be able to get path from form data; need
#      to store page id's with path somehow?
#    - or can we get it from session?

# 3. user entered /some_page.edit in the address bar
#    - need to get path from db

# 4. user clicked on the "Edit" button of some_page
#    - just like with a form submission (maybe this should
#      be a form submission?), we should be able to get
#      path id's from params

    my ($path_pages, $proto_pages) = @$stash{qw/ path_pages proto_pages /};
    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages)
    {
        ($path_pages, $proto_pages) = $m_page_class->path_pages( $path );
    }
    # the page we're editing is at the end of the path
    my $page = ( @$proto_pages > 0 ? $proto_pages->[@$proto_pages - 1] : $path_pages->[@$path_pages -1] );
    # this should never happen!
    die "Cannot determine what page to edit for path: $path" unless $page;
    @$stash{qw/ path_pages proto_pages /} = ($path_pages, $proto_pages);

## We actually don't need this whole block...
      # This needs to be fixed to deal with path strings:
#       if ($proto_page)
#       {
#           $c->form
#           (
#            optional => [qw/read write admin/],
#            defaults =>
#            {
#             #owner=>$editor, # permissions still in flux...
#             creator => $creator,
#            }
#           );
#           # We no longer create a page before displaying
#           # the edit form:
# 	 #$page=$m_class->create_from_form( $c->form );
#       }

      $c->form
      (
       # may need to add more required fields...
       required => [qw/content/],
       defaults=>
       {
        # don't think we need this, even
        #page     => $page || $proto_page,
        # we'll set created in the model
        #created  => localtime->datetime,
        #user     => $editor, # ???
        creator   => $user,
        # don't think we need "previous"
        #previous => ($page ? $page->revision : undef),
        # don't think we need version, etiher
        #version  => ($page ? $page->version + 1 : 1),
       }
      );
      # if we have missing or invalid fields, display the edit form.
      # this will always happen on the initial request
      if ( $c->form->has_missing || $c->form->has_invalid ) {
           $stash->{revision} = $m_rev_class->create_proto( $page );
           $stash->{revision}->{creator} = $user;
	  return;
      }
      # ...else, update the page and redirect to highlight, which will forward to view:
      #my $revision = MojoMojo::M::Core::Revision->create_from_form( $c->form );
      #$page->version( $revision->version );
      #$page->update;
      my $valid = $c->form->valid;
      my $unknown = $c->form->unknown;
      # not implemented yet!
      $m_rev_class->release_new
      (
       proto_rev   => { %$valid, %$unknown },
       # these are needed in case there are any proto pages
       path_pages  => $path_pages,
       proto_pages => $proto_pages,
      );
      $c->res->redirect( $c->req->base . $path . '.highlight' );
}

=item print

this action is the same as the view action, with another template

=cut

sub print : Private {
      my ( $self, $c, $page ) = @_;
      $c->stash->{template} = 'page/print.tt';
      $c->forward('view');
}

sub  attachments : Private {
      my ( $self, $c, $page ) = @_;
      $c->stash->{template} = 'page/attachments.tt';
      $c->forward('view');
      $page=$c->stash->{page};
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
      my ( $self, $c, $page ) = @_;
      $c->stash->{template} = 'page/tags.tt';
      unless (ref $page) {
        $c->forward('view');
        $page=$c->stash->{page};
      }
      my @tags = $page->others_tags($c->req->{user_id});
      $c->stash->{others_tags} = [@tags];
      @tags =$page->user_tags($c->req->{user_id});
      $c->stash->{taglist} = ' '.join(' ',map {$_->tag} @tags).' ' ;
      $c->stash->{tags} =  [@tags];
}
sub list : Path('/.list') {
      my ( $self, $c, $tag ) = @_;
      return $c->forward('/tag/list') if $tag;
      $c->stash->{template} = 'page/list.tt';
      $c->stash->{pages} = [ $m_page_class->retrieve_all_sorted_by('name') ];
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
  my ( $self, $c, $page ) = @_;
  $c->stash->{template} = 'page/rss.tt';
  $c->forward('view');
}

sub atom : Private {
   my ( $self, $c, $page ) = @_;
   $c->stash->{template} = 'page/atom.tt';
   $c->forward('view');
}

sub rss_full : Private  {
   my ( $self, $c, $page ) = @_;
   $c->stash->{template} = 'page/rss_full.tt';
   $c->forward('view');
}

sub highlight : Private {
   my ( $self, $c, $page ) = @_;
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
