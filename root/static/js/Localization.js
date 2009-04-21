if ( typeof Asynapse == 'undefined' ) {
    Asynapse = {}
}

Asynapse.Localization.VERSION = "0.10"

Asynapse.Localization = Object.extend(new Object(), {
    init: function(params) {
        this.lang = params.lang || 'en'
        this.dict_path = params["dict_path"]
        this.dict = this.load_dict(this.lang)
    },
    load_dict: function(lang) {
        var d = { "": "" };
        new Ajax.Request(
            this.dict_path + "/" + this.lang + ".json",
            {
                method: 'get',
                asynchronous: false,
                onComplete: function(t) {
                    eval("d = " + t.responseText)
                }
            }
        )
        return d
    },
    loc: function(str) {
        var dict = this.dict
        if (dict[str]) {
            return dict[str]
        }
        return str
    }
})

Asynapse.Localization.VERSION = "0.10"

_ = Asynapse.Localization.loc.bind(Asynapse.Localization)

/**
=head1 NAME

Asynapse.Localization - Javascript Localization

=head1 VERSION

This document describes Asynapse.Localization version 0.10

=head1 SYNOPSIS

    # Initialize
    Asynapse.Localization.init({
        "lang": "zh_TW",
        "dict_path": "/javascripts/loc"
    })

    # use it
    alert( _("Nihao") )

=head1 DESCRIPTION

This module provides a dictionary-based mechanism to do javascript
string localization. After you initialized it, in your code, you can
call function C<_> (yes, this function name is an underline character)
to turn a string into its localized version.

You should also provide dictionaries json files, defined individually
in a server-side path accessible by XHR. This path is specified by the
value to the key C<"dict_path"> in parameter hash of C<init()>.

JSON dictionaries are named in language codes, for example, "en-us.json" or
"zh_TW.json". If you call init like the code in SYNOPSIS, you should place
your json dictionaries in C</javascripts/loc/zh_TW.json>

The content of these dictionaries looks like:

    {
        "Nihao": "你好",
        "Good bye": "再見"
    }

If you already have .po files in your project, you can convert them
into json dictionaries using C<po2json.pl> in Asynapse project code.
(under C<perl/Asynapse/bin/po2json.pl>).

=over

=item init( params )

You MUST call this function to use this module. C<params> is a hash
that MUST contain at least this two keys: C<lang>, C<dict_path>.

C<lang> is the language code that you want to localize to.
C<dict_path> is the path to .json files.

=item loc( str )

This function translate C<str> to its localized version.

=item load_dict( lang )

This function is internally called by C<init()> to load dictionary
json.

=back

=head1 BUGS AND LIMITATIONS

The asynapse project is hosted at L<http://code.google.com/p/asynapse/>.
You may contact the authors or submit issues using the web interface.

=head1 AUTHOR

Kang-min Liu  C<< <gugod@gugod.org> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, Kang-min Liu C<< <gugod@gugod.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.

=cut

*/
