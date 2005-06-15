package MojoMojo::C::Jsrpc;

use strict;
use base 'Catalyst::Base';

=head1 NAME

MojoMojo::C::Jsrpc - Various jsrpc components.

=head1 SYNOPSIS

This is the Mojo powering our AJAX features.

=head1 DESCRIPTION

This controller dispatches various data to ajax methods in mojomojo

=head1 ACTIONS

=item render (/.jsrpc/render)

Edit uses this to get live preview. It gets some content in 
params->{content} and runs it through the formatter chain.

=cut

sub render : Local {
    my ( $self, $c ) = @_;
    my $output = "Please type something";
    if (   $c->req->params->{content}
        && $c->req->params->{content} =~ /(\S+)/ )
    {
        $output =
          MojoMojo::M::Core::Content->formatted( $c,
          $c->req->params->{content},
          );
    }
    $c->res->output($output);
}

=item child_menu (/.jsrpc/child_menu?page_id=$page_id)

Returns a list of children for the page given by the page_id parameter,
formatted for inclusion in a vertical tree navigation menu.

=cut

sub child_menu : Local {
    my ( $self, $c, $page_id ) = @_;
    $c->stash->{parent_page} = MojoMojo::M::Core::Page->retrieve( $c->req->params->{page_id} );
    $c->stash->{template} = 'child_menu.tt';
}

=item diff (/.jsrpc/diff)

Loads diff on demand. takes an absolute revision number as arg,
and diffs it against the previous version.

=cut

sub diff : Local {
    my ( $self, $c, $page, $revision ) = @_;
    $revision = MojoMojo::M::Core::Content->retrieve(
        page=> $page, 
        version => $revision
    );
    if ( my $previous = $revision->previous ) {
        $c->res->output(
            $revision->formatted_diff( $c, $previous ) );
    }
    else {
        $c->res->output("This is the first revision!");
    }
}

=item submittag (/.jsrpc/submittag)

Add a tag through form submit

=cut

sub submittag : Local {
    my ( $self, $c, $page ) = @_;
    $c->req->args( [ $c->req->params->{tag} ] );
    $c->forward('/jsrpc/tag');
}

=item tag (/.jsrpc/tag)

add a tag to a page. return list of yours and popular tags.

=cut

sub tag : Local {
    my ( $self, $c, $tagname ) = @_;
    ($tagname)= $tagname =~ m/(\w+)/;
    my $page = $c->stash->{page};
    unless (
        ! $tagname ||
        MojoMojo::M::Core::Tag->search(
            page   => $page,
            person => $c->req->{user_id},
            tag    => $tagname
        )->next()
      )
    {
        $page->add_to_tags(
            {
                tag    => $tagname,
                person => $c->req->{user_id}
            }
          )
          if $page;
    }
    $c->req->args( [  $tagname ] );
    $c->forward('/page/tags');
}

=item untag (/.jsrpc/untag)

remove a tag to a page. return list of yours and popular tags.

=cut

sub untag : Local {
    my ( $self, $c, $tagname ) = @_;
    my $page = $c->stash->{page};
    die "Page " . $page . " not found" unless ref $page;
    my $tag = MojoMojo::M::Core::Tag->search(
        page   => $page,
        person => $c->req->{user_id},
        tag    => $tagname
    )->next();
    $tag->delete() if $tag;
    $c->req->args( [ $tagname ] );
    $c->forward('/page/tags');
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>, David Naughton <naughton@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
