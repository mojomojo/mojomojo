package MojoMojo::Formatter::Comment;

sub format_content_order { 91 }

sub format_content {
    my ($self,$content,$c)=@_;
    eval {
    $$content =~ s{\<p\>\=comments\s*}
                  {show_comments($c)}me;
    };
}

sub show_comments {
    $c=shift;
    return '<div id="comments">'.
           $c->subreq("/comment",{page=>$c->stash->{page}}).
           '</div>';
}
1;
