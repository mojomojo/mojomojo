package MojoMojo::Formatter::Scrub;

use base qw/MojoMojo::Formatter/;

use HTML::Scrubber;
use XML::Clean;

=head1 NAME

MojoMojo::Formatter::Scrub - Scrub user HTML
1
=head1 DESCRIPTION

This formatter makes sure only a safe range of tags are 
allowed, using L<HTML::Scrubber>; It also makes sure all tags
are balaced, using L<XML::Clean>.

=head1 METHODS

=over 4

=item format_content_order

Format order can be 1-99. The Comment formatter runs on 1

=cut

sub format_content_order { 1 }

    my @allow = qw[ p img em br hr b a div pre code];

    my @rules = (
        script => 0,
        img => {
            src => qr{^(?!http://)}i, # only relative image links allowed
            alt => 1,                 # alt attribute allowed
            '*' => 0,                 # deny all other attributes
        },
    );

    my @default = (
        0   =>    # default rule, deny all tags
        {
            '*'           => 1, # default rule, allow all attributes
            'href'        => qr{^(?!(?:java)?script)}i,
            'src'         => qr{^(?!(?:java)?script)}i,
            'cite'        => '(?i-xsm:^(?!(?:java)?script))',
            'language'    => 0,
            'name'        => 1, # could be sneaky, but hey ;
            'class'       => 1,
            'onblur'      => 0,
            'onchange'    => 0,
            'onclick'     => 0,
            'ondblclick'  => 0,
            'onerror'     => 0,
            'onfocus'     => 0,
            'onkeydown'   => 0,
            'onkeypress'  => 0,
            'onkeyup'     => 0,
            'onload'      => 0,
            'onmousedown' => 0,
            'onmousemove' => 0,
            'onmouseout'  => 0,
            'onmouseover' => 0,
            'onmouseup'   => 0,
            'onreset'     => 0,
            'onselect'    => 0,
            'onsubmit'    => 0,
            'onunload'    => 0,
            'src'         => 0,
            'type'        => 0,
        }
    );

my $scrubber = HTML::Scrubber->new();
$scrubber->allow( @allow );
$scrubber->rules( @rules ); # key/value pairs
$scrubber->default( @default );
$scrubber->comment(1); # 1 allow, 0 deny


=item format_content

calls the formatter. Takes a ref to the content as well as the
context object.

=cut

sub format_content {
    return 0;
    my ($class,$content,$c)=@_;
    $$content=$scrubber->scrub($$content); 
    return 1;
    #FIXME: XML::Clean doubles the first word in previews
    # but makes sure all divs are matched.
    $$content=XML::Clean::clean($$content);
}

=back

=head1 SEE ALSO

L<MojoMojo>,L<Module::Pluggable::Ordered>,L<XML::Clean>,L<HTML::Scrubber>

=head1 AUTHORS

Marcus Ramberg <mramberg@cpan.org>

=head1 LICENSE

This module is licensed under the same terms as Perl itself.

=cut

1;
