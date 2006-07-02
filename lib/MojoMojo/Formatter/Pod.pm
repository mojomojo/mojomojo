package MojoMojo::Formatter::Pod;


=head1 NAME

MojoMojo::Formatter::Pod - format part of content as POD

=head1 DESCRIPTION

This formatter will format content between two =pod blocks as 
POD (Plain Old Documentation).

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Pod formatter runs on 10

=cut

sub format_content_order { 10 }



=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    my ($class,$content,$c)=@_;

    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    foreach my $line (@lines) {
   	if( $pod ) {
		if ($line =~ m/^=pod\s*$/) { 
         		$$content.=MojoMojo::Formatter::Pod->to_pod($pod,$c->req->base);
			$pod ="";
		} else { $pod .=$line."\n"; }
	} else {
		if ($line =~ m/^=pod\s*$/) { 
			$pod=" "; # make it true :)
		} else { $$content .=$line."\n"; }
	}
    }
}

=item to_pod <pod> <base>

takes some POD documentation, and a base url, and renders it as HTML.

=cut

sub to_pod {
    my ($class,$pod,$base)=@_;
    require Pod::Simple::HTML;
    my $result;
    my $parser = MojoMojo::Formatter::Pod::Simple::HTML->new($base);
    $parser->output_string(\$result); 
    eval {
        $parser->parse_string_document($pod);
    };
    return "<pre>\n$source\n$@\n</pre>\n"
      if $@ or not $result;
    $result =~ s/.*<body.*?>(.*)<\/body>.*/$1/s;
    return qq{<div class="formatter_pod">\n$result</div>};
}

package MojoMojo::Formatter::Pod::Simple::HTML;

# base class for doing links

use base 'Pod::Simple::HTML';

=item Pod::Simple::HTML::new

extended for setting base

=cut
sub new {
	my ($class,$base)=@_;
	my $self= $class->SUPER::new;
	$self->{_base}=$base;
	return $self;
}

=item Pod::Simple::HTML::do_link

Set links based on base

=cut

sub do_link {
    my ($self,$token) = @_;
    my $link = $token->attr('to');
    #FIXME: This doesn't look right:
    return $self->SUPER::do_link($token) unless $link =~ /^$WORD+$/;
    my $section = $token->attr('section');
    $section = "#$section"
      if defined $section and length $section;
    $self->{base} . "$link$section";
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<POD::Tree::HTML>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut


1;
