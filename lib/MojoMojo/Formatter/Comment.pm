package MojoMojo::Formatter::Comment;

=head1 NAME

MojoMojo::Formatter::Comment - Include comments on your page.

=head1 DESCRIPTION

This is a hook for the page comment functionality. It allows a 
comment box to be placed anywhere on your page through the =comments
tag.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Comment formatter runs on 91

=cut

sub format_content_order { 91 }

=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ($self,$content,$c)=@_;
    eval {
    $$content =~ s{\<p\>\=comments\s*}
                  {show_comments($c)}me;
    };
}

=item show_comments

Redispatches a subrequest to L<MojoMojo::C::Comment>.

=cut

sub show_comments {
    $c=shift;
    return '<div id="comments">'.
           $c->subreq("/comment",{page=>$c->stash->{page}}).
           '</div>';
}

=item SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>

=item AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 License

This module is licensed under the same terms as Perl itself.

=cut

1;
