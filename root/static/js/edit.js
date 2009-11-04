$(document).ready(function() {
    var split_edit_button  = $('<a>' + loc('Split Edit') + '</a>');
    var toggle_info_button = $('<a>' + loc('Syntax') + '</a>');
    var content_preview    = $('#content_preview');
    var edit_help          = $('#edithelp');

    set_split_mode( $.cookies.get('split_edit') );
    setup_formatter_toolbar();
    setup_edit_help();
    toggleDefaultValue($('#authorName'));  // auto-clear the 'anonymous_user' name for anon edits

    split_edit_button
        .attr('href', 'action://' + 'split_edit')
        .click(function() {
            toggle_split_mode();
            edit_help.width(content_preview.innerWidth());
            edit_help.height(content_preview.innerHeight());
            return false;
        });

    toggle_info_button
        .attr('href', 'action://' + 'show/syntax_help')
        .click(function() {
            $('#edithelp').toggle();
            edit_help.width(content_preview.innerWidth());
            edit_help.height(content_preview.innerHeight());
            return false;
        });

    $('#pageoptions ul:first').append(
        $('<li/>').append(toggle_info_button),
        $('<li/>').append(split_edit_button)
    );

});

// toggles between horizontal and vertical splitting of the preview and edit areas
var toggle_split_mode = function() {
    if ($.cookies.get('split_edit') == 'horizontal') {
        $.cookies.set('split_edit', 'vertical');
    } else {
        $.cookies.set('split_edit', 'horizontal');
    }
    set_split_mode( $.cookies.get('split_edit') );
};

var set_split_mode = function(split_mode) {
    var window_height = $(window).height();

    if ( split_mode == 'horizontal' ) {
        $('#content_preview').css('width', '100%');
        $('#edit_form').css('width', '100%');
        $('#edit_form').css('float', 'right');

        $('#content_preview').height( window_height * 0.32 );
        $('#body').height( window_height * 0.30 );

        $('#edit_form').css('margin-left', '0');

    } else {
        // split vertically: preview area to the left of edit area
        $('#content_preview').css('width', '49%');
        $('#edit_form').css('float', 'left');
        $('#edit_form').css('margin-left', '1%');
        $('#edit_form').css('width', '48%');

        $('#content_preview').height( window_height * 0.65 );
        $('#body').height( window_height * 0.58 );
    }
};

setup_formatter_toolbar = function() {
    var _create_tolbar_select = function(id, options) {
        var select = $('<select/>');
    
        select.data('opt', options);
        select.attr({ 'id': 'toolbar_' + id.replace(/\s/g, '_'), 'title': loc(id) });
    
        select.append( $('<option>').append(loc(id)) );
    
        $(options).each(function(i) {
            var text = options[i].shift();
            options[i].unshift('body');  // txtarea ID
            select.append( $('<option>').val(i).append(loc(text)) );
        });
    
        select.change(function(){
            var options = select.data('opt');
            if(options[ this.selectedIndex - 1  ]) {
                insertTags.apply(this, options[ this.selectedIndex - 1 ]);
            }
            this.selectedIndex = 0;
            return false;
        });
    
        return select;
    }
    
    var toolbar = $('#formatter_toolbar');
    var wiki_type, buttons;

    $.each(['main', 'textile', 'markdown'], function() {
        if(document.getElementById('syntax_help_' + this)) {
            wiki_type = this;
            return false;
        }
    });

    // Formatter
    toolbar.append(_create_tolbar_select(loc('Formatter'), [
        [ loc('IRC formatter'), '\n{{irc}}\n',  '\n{{end}}\n\n',  '12:00 <nick> Hello #mojomojo!'],
        [ loc('POD formatter'), '\n{{pod}}\n\n','\n\n{{end}}\n\n', loc('=head1 Header')]
    ]));

    // Insert
    toolbar.append(_create_tolbar_select(loc('Insert'), [
        [ loc('comments'), '\n{{comments}}\n', '', ''],
        [ loc('toc'), '\n{{toc}}','',''],
        [ loc('redirect'), '\n{{redirect ', '}}', '/new/location'],
        [ loc('include'), '\n{{', '}}', 'http://www.google.com'],
        [ loc('youtube'), '\n{{youtube ','}}', 'http://www.youtube.com'],
        [ loc('cpan'), '\n{{cpan ', '}}', 'MojoMojo::Formatter']
    ]));

    // make sure it is initialized
    if(typeof syntax_formatters != 'object') {
        syntax_formatters = [];
    }

    // Syntax highlight
    toolbar.append(_create_tolbar_select(loc('Syntax Highlight'),
        $.map(syntax_formatters, function(n, i) {
            return [[ n, '\n\n<pre lang=\"' + n + '\">\n','\n</pre>\n\n',loc('say "Howdy partner.";') ]];
        })
    ));

    toolbar.append('<br>');

    // main or textile buttons
    if(wiki_type == 'main' || wiki_type == 'textile') {
        buttons = [
            [ 'heading', loc('Main heading'), '\n\nh1. ','\n\n',loc('Also try h2, h3 and so on')],
            [ 'list_bullet', loc('Bullet list'), '\n\n* ', '\n\n', loc('List item 1')],
            [ 'list_enum', loc('Enum list'), '\n\n# ', '\n\n', loc('Numbered list item')],
            [ 'insert_table',  loc('Insert table'),  '\n'+
                                                     '|','|||\n'+
                                                     '|'+loc('Cell')+'|'+loc('Cell')+'|'+loc('Cell')+'|\n'
              ,loc('Table')
            ],
            [ 'code', loc('Code'), '@', '@', loc('code')],
            [ 'quote', loc('Block quote'), '\nbq. ','', loc('quote')],
            [ 'left', loc('Left-justified paragraph'), '\n\np<. ','\n\n', loc('left justified paragraph')],
            [ 'right', loc('Right-justified paragraph'), '\n\np>. ','\n\n', loc('right justified paragraph')],
            [ 'center', loc('Centered paragraph'), '\n\np=. ','\n\n', loc('centered paragraph')],
            [ 'justify', loc('Justified paragraph'), '\n\np<>. ','\n\n', loc('justified paragraph')],
            [ 'bold', loc('Bold'), '*', '*', loc('bold')],
            [ 'italic', loc('Italic'), '_','_', loc('italic')],
            [ 'strikethrough', loc('Deleted text'), '-', '-', loc('deleted')],
            [ 'big', loc('Bigger'), '++','++', loc('bigger')],
            [ 'small', loc('Smaller'), '--','--', loc('small')],
            [ 'super', loc('Superscript'), '^','^', loc('superscript')],
            [ 'sub', loc('Subscript'), '[~','~]', loc('subscript')],
            [ 'wikilink', loc('Internal link'), '[[/path/to/page|', ']]', loc('Intrawiki link')],
            [ 'hyperlink', loc('External link'), '"', '":URL', loc('linked text')],
            [ 'drawing_left',  loc('Picture left'),  '<div class="photo" style="float: left">!<',  '!</div>','/.static/catalyst.png(Catalyst)'],
            [ 'drawing',       loc('Picture'),       '<div class="photo">!',                       '!</div>','/.static/catalyst.png(Catalyst)'],
            [ 'drawing_right', loc('Picture right'), '<div class="photo" style="float: right">!>', '!</div>','/.static/catalyst.png(Catalyst)']
        ];
    }

    // markdown buttons
    else if(wiki_type = 'markdown') {
        buttons = [
            [ 'heading', loc('Main heading'), '\n\n# ',' #\n\n', loc('increase # for smaller headline')],
            [ 'list_bullet', loc('Bullet list'), '\n\n* ','\n\n', loc('List item 1')],
            [ 'list_enum', loc('Enum list'), '\n\n1. ', '\n\n', loc('Numbered list item')],
            [ 'insert_table',  loc('Insert table'),  '\n|             |          '+loc('Grouping')+'           ||\n'+
              loc('First Header')+'  | '+loc('Second Header')+' | '+loc('Third Header')+' |\n'+
              ' ------------ | :-----------: | -----------: |\n'+
              loc('Content')+'       |          *'+loc('Long Cell')+'*        ||\n'+
              loc('Content')+'       |   **'+loc('Cell')+'**    |         '+loc('Cell')+' |\n'+
              '[', ']\n\n', loc('Table Title')
            ],
            [ 'quote', loc('Block quote'), '> ','', loc('quote')],
            [ 'code', loc('Code'), '`', '`', loc('code')],
            [ 'bold', loc('Bold'), '**','**', loc('bold')],
            [ 'italic', loc('Italic'),'_','_', loc('italic')],
            //[ 'strikethrough', loc('Deleted Text'), '-', '-', loc('deleted')],
            [ 'wikilink', loc('Internal link'), '[[/path/to/page|', ']]', loc('Intrawiki link')],
            [ 'hyperlink', loc('External link'), '['+loc('linked text')+'](', ')', 'URL'],
            [ 'drawing_left',  loc('Picture left'),  '<div markdown="1" class="photo" style="float: left">![alt text](',  ' "Title")</div>', '/.static/catalyst.png' ],
            [ 'drawing',       loc('Picture'),       '<div markdown="1" class="photo">![alt text](',                      ' "Title")</div>', '/.static/catalyst.png' ],
            [ 'drawing_right', loc('Picture right'), '<div markdown="1" class="photo" style="float: right">![alt text](', ' "Title")</div>', '/.static/catalyst.png' ]
        ];
    }

    // create and apply buttons
    $(buttons).each(function() {
        var data = this;
        var button = $('<input type="image">');

        button.attr({
            'src': $.uri_for('/.static/toolbar/' + data.shift() + '.png'),
            'title': loc(data.shift())
        });

        data.unshift('body'); // txtarea ID
        button.click(function() { return insertTags.apply(this, data); });
        toolbar.append(button);
    });

    // help text
    toolbar.append(
          '<br><small>&nbsp;'
        + loc('Mark some text to apply the toolbar actions to that text')
        + '</small>'
    );
};

var setup_edit_help = function() {
    var edithelp = $('#edithelp');
    var nav      = $('<div class="tab-nav"/>');
    var close    = $('<a href="action://close" class="close-button"><span>X</span></a>');
    var tabs      = [];

    edithelp.children('.syntax_help').each(function() {
        var tab  = $(this);
        var a    = $('<a/>');
        var title = tab.children('h2:first').text();
        var id    = this.id;

        a.append(title).attr('href', 'tab://' + title).click(function() {
            $.each(tabs, function() {
                this[0].removeClass('active');
                this[1].hide();
            });
            tab.show();
            a.addClass('active');
            return false;
        });

        tabs.push([a, tab]);
        nav.append(a);
    });

    close.click(function() { edithelp.hide(); return false });

    tabs[0][0].click();
    nav.append(close);
    edithelp.prepend(nav);

    return tabs;
};
