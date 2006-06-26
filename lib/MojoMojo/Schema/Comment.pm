package MojoMojo::Schema::Comment;

# Created by DBIx::Class::Schema::Loader v0.03003 @ 2006-06-18 12:23:29

use strict;
use warnings;

use base 'DBIx::Class';


use Text::Textile2();
my $textile=Text::Textile2->new(
    disable_html=>1,
    flavor=>'xhtml2',
    charset=>'utf8',
    char_encoding=>1
);

__PACKAGE__->load_components(qw/DateTime::Epoch PK::Auto Core/);
__PACKAGE__->table("comment");
__PACKAGE__->add_columns("id", 
    "poster", 
    "page", 
    "picture", 
    "posted" => {data_type=>'bigint',epoch=>'ctime'}, 
    "body");
__PACKAGE__->set_primary_key("id");
__PACKAGE__->belongs_to("poster", "Person", { id => "poster" });
__PACKAGE__->belongs_to("page", "Page", { id => "page" });
__PACKAGE__->belongs_to("picture", "Photo", { id => "picture" });


=item formatted

Returns a textile formatted version of the given comment.

=cut

sub formatted {
  my $self=shift;
  return $textile->process($self->body);
};

1;
