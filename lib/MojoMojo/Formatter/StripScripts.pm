package MojoMojo::Formatter::StripScripts;

use strict;
use warnings FATAL => 'all';

use HTML::StripScripts::Parser();
our @ISA = qw(HTML::StripScripts::Parser);

### NOTE - When changing the values of any of these hashes, first copy the hash
###        and THEN change the values. For instance:
###
###           my %head = %{$Context{Head}};
###           $head{meta} = 'EMPTY';
###           $Context{Head} = \%head
###
###        This will ensure that the original
###        HTML::StripScripts will still work as expected.

our ( %Context, %Attrib );

### Add <meta> and <link> tags to <head>
sub init_context_whitelist {
    my ($self) = @_;
    unless (%Context) {
        %Context = %{ $self->SUPER::init_context_whitelist };

        my %flow = %{ $Context{Flow} };
        $flow{a}       = 'Inline';
        $flow{pre}     = 'pre.content';
        $flow{span}    = 'Inline';
        $flow{div}     = 'Flow';
        $Context{Flow} = \%flow;
    }
    return \%Context;
}

### Add attributes for the <meta> and <link> tags
sub init_attrib_whitelist {
    my ($self) = @_;
    unless (%Attrib) {
        %Attrib = %{ $self->SUPER::init_attrib_whitelist };

        $Attrib{a} = {
            'href'  => 'href',
            'title' => 'text',
            'class' => 'text',
            'span'  => 'text',
        };
        $Attrib{pre} = { 'lang' => 'text', };
        $Attrib{span} = {
            'style' => 'text',
            'class' => 'text',
        };
        $Attrib{div} = {
            'class' => 'text',
            'style' => 'text',
        };
    }
    return \%Attrib;
}

1;
