package MojoMojo::Controller::Jsrpc;

use strict;
use base 'Catalyst::Controller';
use HTML::Entities;
use utf8;

=head1 NAME

MojoMojo::Controller::Jsrpc - Various JsRPC functions.

=head1 SYNOPSIS

This is the Mojo powering our AJAX features. 

=head1 DESCRIPTION

This controller dispatches various data to ajax methods in mojomojo
These methods will be called indirectly through javascript functions.

=head1 ACTIONS

=over 4

=item render (/.jsrpc/render)

Edit uses this to get live preview. It gets some content in 
params->{content} and runs it through the formatter chain.

=cut

sub render : Local {
    my ( $self, $c ) = @_;
    my $output = "Please type something";
    my $input  = $c->req->params->{content};
    if ( $input && $input =~ /(\S+)/ ) {
        $output = $c->model("DBIC::Content")->format_content( $c, $input );
    }

    unless ($output) {
        $output = 'Your input is invalid, please reformat it and try again.';
        $c->res->status(500);
    }

    utf8::decode($output);
    $c->res->output($output);
}

=item child_menu (/.jsrpc/child_menu?page_id=$page_id)

Returns a list of children for the page given by the page_id parameter,
formatted for inclusion in a vertical tree navigation menu.

=cut

sub child_menu : Local {
    my ( $self, $c, $page_id ) = @_;
    $c->stash->{parent_page} = $c->model("DBIC::Page")->find( $c->req->params->{page_id} );
    $c->stash->{template}    = 'child_menu.tt';
}

=item diff (/.jsrpc/diff)

Loads diff on demand. takes an absolute revision number as arg,
and diffs it against the previous version.

=cut

sub diff : Local {
    my ( $self, $c, $page, $revision, $against, $sparse ) = @_;
    unless ($revision) {
        my $page = $c->model("DBIC::Page")->find($page);
        $revision = $page->content->id;
    }
    $revision = $c->model("DBIC::Content")->search(
        {
            page    => $page,
            version => $revision
        }
    )->next;
    if (
        my $previous = $against
        ? $c->model("DBIC::Content")->search(
            {
                page    => $page,
                version => $against
            }
        )->next
        : $revision->previous
        )
    {
        $c->res->output( $revision->formatted_diff( $c, $previous, $sparse ) );
    }
    else {
        $c->res->output("This is the first revision! Nothing to diff against.");
    }
}

=item submittag (/.jsrpc/submittag)

Add a tag through form submit

=cut

sub submittag : Local {
    my ( $self, $c, $page ) = @_;
    $c->forward( '/jsrpc/tag', [ $c->req->params->{tag} ] );
}

=item tag (/.jsrpc/tag)

add a tag to a page. return list of yours and popular tags.

=cut

sub tag : Local Args(1) {
    my ( $self, $c, $tagname ) = @_;
    ($tagname) = $tagname =~ m/([\w\s]+)/;
    my $page = $c->stash->{page};
    foreach my $tag ( split m/\s/, $tagname ) {
        if (
            $tag
            && !$c->model("DBIC::Tag")->search(
                page   => $page->id,
                person => $c->req->{user_id},
                tag    => $tagname
            )->next()
            )
        {
            $page->add_to_tags(
                {
                    tag    => $tag,
                    person => $c->stash->{user}->id
                }
            ) if $page;
        }
    }
    $c->req->args( [$tagname] );
    $c->forward('/page/inline_tags');
}

=item untag (/.jsrpc/untag)

remove a tag to a page. return list of yours and popular tags.

=cut

sub untag : Local Args(1) {
    my ( $self, $c, $tagname ) = @_;
    my $page = $c->stash->{page};
    die "Page " . $page . " not found" unless ref $page;
    my $tag = $c->model("DBIC::Tag")->search(
        page   => $page->id,
        person => $c->user->obj->id,
        tag    => $tagname
    )->next();
    $tag->delete() if $tag;
    $c->req->args( [$tagname] );
    $c->forward('/page/inline_tags');
}

=item imginfo (.jsrpc/imginfo)

Inline info on hoved for gallery photos. 

=cut

sub imginfo : Local {
    my ( $self, $c, $photo ) = @_;
    $c->stash->{photo}    = $c->model("DBIC::Photo")->find($photo);
    $c->stash->{template} = 'gallery/imginfo.tt';
}

=back

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>, David Naughton <naughton@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
