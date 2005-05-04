package MojoMojo::Search::Plucene;

use strict;
use base 'Plucene::Simple';
use Plucene::Plugin::Analyzer::SnowballAnalyzer;

# TODO:
# Use Text::Context to display text snippets from search results
# I can't find a way to index the path data such that we can search only a subsection of
#   the path tree.  For now, we can simply get all search results and ignore those that don't
#   have a key that matches the path we are looking for.

# Not all analyzers are created equal...the SnowballAnalyzer appears to work the best
sub _parsed_query {
	my ($self, $query, $default) = @_;
	my $parser = Plucene::QueryParser->new({
			analyzer => Plucene::Plugin::Analyzer::SnowballAnalyzer->new(),
			default  => $default
		});
	$parser->parse($query);
}

sub _writer {
	my $self = shift;
	return Plucene::Index::Writer->new(
		$self->_dir,
		Plucene::Plugin::Analyzer::SnowballAnalyzer->new(),
		0
	);
}

# updates the search index when page data changes
sub update_index {
    my ($self, $page) = @_;
    return undef unless ($page);
    
    # XXX: TODO
}

1;
