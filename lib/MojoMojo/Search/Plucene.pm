package MojoMojo::Search::Plucene;

use strict;
use base 'Plucene::Simple';

# updates the search index when page data changes
sub update_index {
    my ($self, $page) = @_;
    return undef unless ($page);
    
    # XXX: TODO
}

1;
