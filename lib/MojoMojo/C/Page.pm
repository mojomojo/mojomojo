package MojoMojo::C::Page;

use strict;
use base 'Catalyst::Base';
use IO::Scalar;
use URI;
use Time::Piece;
use File::MimeInfo::Magic;
my $m_base          = 'MojoMojo::M::Core::';
my $m_page_class    = $m_base . 'Page';
my $m_content_class = $m_base . 'Content';
my $m_verison_class = $m_base . 'PageVersion';

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

    my ( $path_pages, $proto_pages ) = @$stash{qw/ path_pages proto_pages /};

    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages) {
        ( $path_pages, $proto_pages ) = $m_page_class->path_pages($path);
        @$stash{qw/ path_pages proto_pages /} = ( $path_pages, $proto_pages );
    }

    # WARNING! there may be potential for an infinite loop here,
    # bouncing back and forth between "edit" and "view"
    return $c->forward('edit') if @$proto_pages;

    my $page = $path_pages->[ @$path_pages - 1 ];
    $stash->{page} = $page;

    my $content;

    # This form/rev stuff doesn't seem to work...
    my $rev = $c->req->params->{rev};
    if ( $rev && defined $page->content_version ) {
        $content = MojoMojo::M::Core::Content->retrieve(
            page    => $page->id,
            version => $rev
        );
        $stash->{rev} = ( defined $content ? $content->version : undef );
        $stash->{template} = 'norevision.tt' unless $stash->{rev};
    }
    else {
        $content = $page->content;
    }
    $stash->{content} = $content;

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
    $c->forward('/user/login') if $c->req->params->{login} && !$c->req->{user};

    my $user = $c->req->{user_id} || 0;

    my ( $path_pages, $proto_pages ) = @$stash{qw/ path_pages proto_pages /};

    # we should always have at least "/" in path pages. if we don't,
    # we must not have had these structures in the stash
    unless ($path_pages) {
        ( $path_pages, $proto_pages ) = $m_page_class->path_pages($path);
    }

    # the page we're editing is at the end of either path_pages or proto_pages,
    # depending on whether or not the page already exists:
    my $page =
      (   @$proto_pages > 0
        ? $proto_pages->[ @$proto_pages - 1 ]
        : $path_pages->[ @$path_pages - 1 ] );

    # this should never happen!
    die "Cannot determine what page to edit for path: $path" unless $page;
    @$stash{qw/ path_pages proto_pages /} = ( $path_pages, $proto_pages );

    $c->form(

        # may need to add more required fields...
        required => [qw/body/],
        defaults => { creator => $user, }
    );

    # if we have missing or invalid fields, display the edit form.
    # this will always happen on the initial request
    if ( $c->form->has_missing || $c->form->has_invalid ) {
        $stash->{page}    = $page;
        $stash->{content} = MojoMojo::M::Core::Content->create_proto($page);
        $stash->{content}->{creator} = $user;
        return;
    }

  # else, update the page and redirect to highlight, which will forward to view:
    my $valid   = $c->form->valid;
    my $unknown = $c->form->unknown;

    if (@$proto_pages)    # page doesn't exist yet
    {
        $path_pages = $m_page_class->create_path_pages(
            path_pages  => $path_pages,
            proto_pages => $proto_pages,
        );
        $page = $path_pages->[ @$path_pages - 1 ];
    }
    $page->update_content( %$valid, %$unknown );

    # This is another ugly hack that needs to be fixed,
    # especially if we ever support relative links of
    # the form "./" and/or "../". Hmm... actually, we
    # just need to make sure that paths never start with
    # those relative operators, since base never has a
    # trailing slash anymore. Also, paths starting with
    # "../" would make no sense, anyway.
    unless ( $path =~ /^\// ) {
        $path = '/' . $path;
    }
    $c->res->redirect( $c->req->base . $path . '.highlight' );

}    # end sub edit

=item print

this action is the same as the view action, with another template

=cut

sub print : Private {
    my ( $self, $c, $page ) = @_;
    $c->stash->{template} = 'page/print.tt';
    $c->forward('view');
}

sub attachments : Private {
    my ( $self, $c, $page ) = @_;
    $c->stash->{template} = 'page/attachments.tt';
    $c->forward('view');
    $page = $c->stash->{page};
    if ( my $file = $c->req->params->{file} ) {
        my $att =
          MojoMojo::M::Core::Attachment->create(
            { name => $file, page => $page } );

        my $fh       = $c->req->uploads->{$file}->{fh};
        my $filename = $c->home . "/uploads/" . $att->id;
        open( NEW_FILE, ">$filename" )
          or die "Can't open $filename for writing: $!";
        while ( $fh->read( my $buf, 32768 ) ) {
            print NEW_FILE $buf;
        }
        close NEW_FILE;
        $att->contenttype( mimetype($filename) );
        $att->size( -s $filename );
        $att->update();
    }
}

sub tags : Private {
    my ( $self, $c, $page, $highlight ) = @_;
    $c->stash->{template}  = 'page/tags.tt';
    $c->stash->{highlight} = $highlight;
    unless ( ref $page ) {
        $c->forward('view');
        $page = $c->stash->{page};
    }
    else {
        $c->stash->{page} = $page;
    }
    die $page . " not found" unless ref $page;
    my @tags = $page->others_tags( $c->req->{user_id} );
    $c->stash->{others_tags} = [@tags];
    @tags                    = $page->user_tags( $c->req->{user_id} );
    $c->stash->{taglist}     = ' ' . join( ' ', map { $_->tag } @tags ) . ' ';
    $c->stash->{tags}        = [@tags];
}

sub list : Path('/.list') {
    my ( $self, $c, $tag ) = @_;
    return $c->forward('/tag/list') if $tag;
    $c->stash->{template} = 'page/list.tt';
    $c->stash->{pages}    = [ $m_page_class->retrieve_all_sorted_by('name') ];

    # FIXME - real data here please
    $c->stash->{orphans} = [];
    $c->stash->{wanted}  = [];
    $c->stash->{tags}    = [ MojoMojo::M::Core::Tag->search_most_used() ];
}

sub recent : Path('/.recent') {
    my ( $self, $c, $tag ) = @_;
    return $c->forward('/tag/recent') if $tag;
    $c->stash->{template} = 'page/recent.tt';
    $c->stash->{tags}     = [ MojoMojo::M::Core::Tag->search_most_used ];
    $c->stash->{pages}    = [ MojoMojo::M::Core::Page->search_recent ];

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

sub rss_full : Private {
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
