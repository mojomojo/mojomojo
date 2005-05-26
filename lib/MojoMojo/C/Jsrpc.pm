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

sub render : Path('/.jsrpc/render') {
    my ( $self, $c ) = @_;
    my $output = "Please enter something";
    if (   $c->req->params->{content}
        && $c->req->params->{content} =~ /(\S+)/ )
    {
        $output =
          MojoMojo::M::Core::Content->formatted( $c->req->base,
            $c->req->params->{content},
          );
    }
    $c->res->output($output);
}

=item diff (/.jsrpc/diff) 

Loads diff on demand. takes an absolute revision number as arg,
and diffs it against the previous version.

=cut

sub diff : Path('/.jsrpc/diff') {
    my ( $self, $c, $page, $revision ) = @_;
    $revision = MojoMojo::M::Core::Content->retrieve(
        page=> $page, 
        version => $revision
    );
    if ( my $previous = $revision->previous ) {
        $c->res->output(
            $revision->formatted_diff( $c->req->base, $previous ) );
    }
    else {
        $c->res->output("This is the first revision!");
    }
}

=item submittag (/.jsrpc/submittag)

Add a tag through form submit

=cut

sub submittag : Path('/.jsrpc/submittag') {
    my ( $self, $c, $page ) = @_;
    $c->req->args( [ $page, $c->req->params->{tag} ] );
    $c->forward('/jsrpc/tag');
}

=item tag (/.jsrpc/tag)

add a tag to a page. return list of yours and popular tags.

=cut

sub tag : Path('/.jsrpc/tag') {
    my ( $self, $c, $page, $tagname ) = @_;
    ($tagname)= $tagname =~ m/(\w+)/;
    $page = MojoMojo::M::Core::Page->retrieve($page);
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
    $c->req->args( [ $page, $tagname ] );
    $c->forward('/page/tags');

}

=item untag (/.jsrpc/untag)

remove a tag to a page. return list of yours and popular tags.

=cut

sub untag : Path('/.jsrpc/untag') {
    my ( $self, $c, $page, $tagname ) = @_;
    $page = MojoMojo::M::Core::Page->retrieve($page);
    die "Page " . $page . " not found" unless ref $page;
    my $tag = MojoMojo::M::Core::Tag->search(
        page   => $page,
        person => $c->req->{user_id},
        tag    => $tagname
    )->next();
    $tag->delete() if $tag;
    $c->req->args( [ $page, $tagname ] );
    $c->forward('/page/tags');
}

=head1 AUTHOR

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
