package MojoMojo::M::Core::Preference;

__PACKAGE__->columns(Essential=>qw/prefvalue/);
__PACKAGE__->default_search_attributes( { use_resultset_cache => 1 });

1;
