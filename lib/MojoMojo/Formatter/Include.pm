package MojoMojo::Formatter::Include;

use LWP::Simple;
sub format_content_order { 5 }
sub format_content {
    my ($self,$content,$base)=@_;

    my @lines=split /\n/,$$content;
    my $pod;$$content="";
    foreach my $line (@lines) {
	if ($line =~ m/^=include\s+(.+)$/) { 
         		$$content.=MojoMojo::Formatter::Include->include($1);
	} else {
	    $$content .=$line."\n";	
	}
    }
}

sub include {
    my ($self,$url)=@_;
    my $content=get($url);
    return $content if defined $content;
    return "Could not retrieve $url .\n";
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
    my $base="/mitiki";
    my $link = $token->attr('to');
    return super unless $link =~ /^$WORD+$/;
    my $section = $token->attr('section');
    $section = "#$section"
      if defined $section and length $section;
    $self->{base} . "/page/view/$link$section";
}



1;
