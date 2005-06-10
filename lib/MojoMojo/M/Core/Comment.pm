package MojoMojo::M::Core::Comment;

use Text::Textile2();
my $textile=Text::Textile2->new(disable_html=>1,flavor=>'xhtml2', charset=>'utf8', char_encoding=>1);

__PACKAGE__->has_a(
    posted => 'DateTime',
    inflate => sub {
        DateTime->from_epoch(epoch=>shift);
    },
    deflate => 'epoch'
);


sub formatted {
  my $self=shift;
  return $textile->process($self->body);
};

1;
