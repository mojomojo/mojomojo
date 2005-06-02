package MojoMojo::Formatter::Pod;

use Pod::Tree::HTML;
sub format_content_order { 10 }
sub format_content {
    my ($self,$content,$c)=@_;

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

sub to_pod {
    my ($self,$pod,$base)=@_;
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

use base 'Pod::Simple::HTML';
sub new {
	my ($class,$base)=@_;
	my $self= $class->SUPER::new;
	$self->{_base}=$base;
	return $self;
}

sub do_link {
    my ($self,$token) = @_;
    my $link = $token->attr('to');
    return $self->SUPER::do_link($token) unless $link =~ /^$WORD+$/;
    my $section = $token->attr('section');
    $section = "#$section"
      if defined $section and length $section;
    $self->{base} . "/page/view/$link$section";
}



1;
