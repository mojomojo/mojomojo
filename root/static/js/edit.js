$(document).ready(function() {
    var $split_edit_button  = $('<a>' + loc('Split Edit') + '</a>');
    var $toggle_info_button = $('<a>' + loc('Syntax') + '</a>');
    var $content_preview    = $("#content_preview");
    var $edit_help          = $("#edithelp");

    setupFormatterToolbar();
    setupEditHelp();
    toggleDefaultValue($("#authorName"));

    $split_edit_button
        .attr('href', 'action://' + 'split_edit')
        .click(function() {
            toggle_split_mode();
            $edit_help.width($content_preview.innerWidth());
            $edit_help.height($content_preview.innerHeight());
            return false;
        });

    $toggle_info_button
        .attr('href', 'action://' + 'show/syntax_help')
        .click(function() {
            $("#edithelp").toggle();
            $edit_help.width($content_preview.innerWidth());
            $edit_help.height($content_preview.innerHeight());
            return false;
        });

    $("#pageoptions ul:first").append(
        $('<li/>').append($toggle_info_button),
        $('<li/>').append($split_edit_button)
    );

    if($.cookies.get('split_edit')=='1'){
        $split_edit_button.click();
    }
});

// toggles between horizontal and vertical splitting of the preview and edit areas
toggle_split_mode = function() {
    var max_container_width       = $(window).width();
    // At one point preview was allowed to grown in the vertical dimension
	//var preview_area_height       = '100%';
    var edit_area_height          = '40em';
	// This a bit taller than the edit area 
	// because we don't have toolbars and such in preview.
	var preview_area_height       = '50em';
    var preview_area_max_width    = max_container_width/2;
    var $content_preview          = $("#content_preview");
   
    if ($("div#edit_form").css('float')=='left'){
        // switch to horizontal split: preview area above edit area
        $("div#edit_form").css('float',toggle_split_mode.deff);
        $content_preview.css('float',toggle_split_mode.dcpf);
        $content_preview.css('width',toggle_split_mode.dcpw);
        $content_preview.css('height', '100%');
        $("div#edit_form").css('width',toggle_split_mode.defw);
        $("div#container").css("max-width",toggle_split_mode.dcmw);
        $("div#header").css("background-repeat",toggle_split_mode.dhbr);
        $content_preview.css("height",toggle_split_mode.dph);
        $("textarea#body").css("height",toggle_split_mode.tbh);
        //$("div.preview").css("max-width",toggle_split_mode.dpmw);
        $content_preview.css("max-width",'100%');
        $.cookies.set('split_edit',0);
    } else {
        // switch to vertical split: preview area to the left of edit area
        toggle_split_mode.deff=$('div#edit_form').css('float');
        toggle_split_mode.dcpf=$content_preview.css('float');
        toggle_split_mode.dcpw=$content_preview.css('width');
        toggle_split_mode.defw=$('div#edit_form').css('width');
        toggle_split_mode.dcmw=$('div#container').css('max-width');
        toggle_split_mode.dhbr=$('div#header').css('background-repeat');
        toggle_split_mode.dph=$content_preview.css('height');
        toggle_split_mode.tbh=$('textarea#body').css('height');
        //toggle_split_mode.dpmw=$('div.preview').css('max-width');
        $("div#edit_form").css('float','left');
        $("div#edit_form").css('width','49%');
        $content_preview.css('float','left');
        $content_preview.css('width','49%');
        $content_preview.css('height', preview_area_height );
        $("div#container").css("max-width", max_container_width);
        $("div#header").css('background-repeat', 'no-repeat');
        $("textarea#body").css('height', edit_area_height);
        $content_preview.css('max-width', preview_area_max_width);
        $content_preview.css('margin-right','1em');
        $.cookies.set('split_edit',1);
    }
};

_createToolbarSelect = function(id, options) {
    var $select = $('<select/>');

    $select.data('opt', options);
    $select.attr({ 'id': "toolbar_" + id.replace(/\s/g, "_"), 'title': loc(id) });

    $select.append( $('<option>').append(loc(id)) );

    $(options).each(function(i) {
        var text = options[i].shift();
        options[i].unshift('body'); // txtarea ID
        $select.append( $('<option>').val(i).append(loc(text)) );
    });

    $select.change(function(){
        var options = $select.data('opt');
        if(options[ this.selectedIndex - 1  ]) {
            insertTags.apply(this, options[ this.selectedIndex - 1 ]);
        }
        this.selectedIndex = 0;
        return false;
    });

    return $select;
}

setupFormatterToolbar = function() {
    var $toolbar = $("#formatter_toolbar");
    var wiki_type, buttons;

    $.each(['main', 'textile', 'markdown'], function() {
        if(document.getElementById('syntax_help_' + this)) {
            wiki_type = this;
            return false;
        }
    });

    // Formatter
    $toolbar.append(_createToolbarSelect(loc('Formatter'), [
        [ loc('IRC formatter'), '\n{{irc}}\n',  '\n{{end}}\n\n',  '12:00 <nick> Hello #mojomojo!'],
        [ loc('POD formatter'), '\n{{pod}}\n\n','\n\n{{end}}\n\n',loc("=head1 Header")]
    ]));

    // Insert 
    $toolbar.append(_createToolbarSelect(loc('Insert'), [
        [ loc('comments'), '\n{{comments}}\n','',''],
        [ loc('toc'), '\n{{toc}}','',''],
        [ loc('redirect'), '\n{{redirect ','}}','/new/location'],
        [ loc('include'), '\n{{','}}','http://www.google.com'],
        [ loc('youtube'), '\n{{youtube ','}}','http://www.youtube.com'],
        [ loc('cpan'), '\n{{cpan ','}}','MojoMojo']
    ]));

    // make sure it is initialized
    if(typeof syntax_formatters != 'object') {
        syntax_formatters = [];
    }

    // Syntax highlight
    $toolbar.append(_createToolbarSelect(loc('Syntax Highlight'), 
        $.map(syntax_formatters, function(n, i) {
            return [[ n, '\n\n<pre lang=\"' + n + '\">\n','\n</pre>\n\n',loc('say "Howdy partner.";') ]];
        })
    ));

    $toolbar.append('<br>');

    // main or textile buttons
    if(wiki_type == 'main' || wiki_type == 'textile') {
        buttons = [
            [ 'heading', loc('Main heading'), '\n\nh1. ','\n\n',loc('Also try h2,h3 and so on')],
            [ 'list_bullet', loc('Bullet list'), '\n\n* ','\n\n',loc('List item 1')],
            [ 'list_enum', loc('Enum list'), '\n\n# ','\n\n',loc('Numbered list item')],
            [ 'code', loc('Code'), '@','@',loc('code')],
            [ 'quote', loc('Block quote'), 'bq. ','',loc('quote')],
            [ 'left', loc('Left-justified paragraph'), '\n\np<. ','\n\n',loc('left justified paragraph')],
            [ 'right', loc('Right-justified paragraph'), '\n\np>. ','\n\n',loc('right justified paragraph')],
            [ 'center', loc('Centered paragraph'), '\n\np=. ','\n\n',loc('centered paragraph')],
            [ 'justify', loc('Justified paragraph'), '\n\np<>. ','\n\n',loc('justified paragraph')],
            [ 'bold', loc('Bold'), '*','*',loc('bold')],
            [ 'italic', loc('Italic'), '_','_',loc('italic')],
            [ 'strikethrough', loc('Deleted Text'), '-','-',loc('deleted')],
            [ 'big', loc('Bigger'), '++','++',loc('bigger')],
            [ 'small', loc('Smaller'), '--','--',loc('small')],
            [ 'super', loc('Superscript'), '^','^',loc('superscript')],
            [ 'sub', loc('Subscript'), '[~','~]',loc('subscript')],
            [ 'wikilink', loc('Internal Link'), '[[',']]','/MojoMojo|Interwiki Link'],
            [ 'hyperlink', loc('External Link'), '&quot;','&quot;:/','link(hyper)'],
            [ 'drawing_left', loc('Picture left'), '<div class=photo>!<','!</div>','/.static/catalyst.png(Catalyst)'],
            [ 'drawing', loc('Picture'), '<div class=photo>!','!</div>','/.static/catalyst.png(Catalyst)'],
            [ 'drawing_right', loc('Picture Right'), '<div class=photo>!>','!</div>','/.static/catalyst.png(Catalyst)']
        ];
    }

    // markdown buttons
    else if(wiki_type = 'markdown') {
        buttons = [
            [ 'heading', loc('Main heading'), '\n\n# ',' #\n\n',loc('increase # for smaller headline')],
            [ 'list_bullet', loc('Bullet list'), '\n\n* ','\n\n',loc('List item 1')],
            [ 'list_enum', loc('Enum list'), '\n\n1. ','\n\n',loc('Numbered list item')],
            [ 'bold', loc('Bold'), '**','**',loc('bold')],
            [ 'italic', loc('Italic'),'_','_', loc('italic')],
            [ 'strikethrough', loc('Deleted Text'), '-','-',loc('deleted')],
            [ 'wikilink', loc('Internal Link'), '[[',']]','/MojoMojo|Interwiki Link'],
            [ 'hyperlink', loc('External Link'), '[',']()',loc('url inside paranthesis')],
            [ 'drawing_left', loc('Picture left'), '<div class=photo style=&quot;float: left&quot;>![alt text](', ' &quot;Title&quot;)</div>', '/.static/catalyst.png' ],
            [ 'drawing', loc('Picture'), '<div class=photo>![alt text](', ' &quot;Title&quot;)</div>', '/.static/catalyst.png' ],
            [ 'drawing_right', loc('Picture Right'), '<div class=photo style=&quot;float: right&quot;>![alt text](', ' &quot;Title&quot;)</div>', '/.static/catalyst.png' ]
        ];
    }

    // create and apply buttons
    $(buttons).each(function() {
        var data = this;
        var $button = $('<input type="image">');

        $button.attr({
            'src': $.uri_for('/.static/toolbar/' + data.shift() + '.png'),
            'title': loc(data.shift())
        });

        data.unshift('body'); // txtarea ID
        $button.click(function() { return insertTags.apply(this, data); });
        $toolbar.append($button);
    });

    // help text
    $toolbar.append(
          '<br><small>&nbsp;'
        + loc('Mark some text to apply the toolbar actions to that text')
        + '</small>'
    );
};

setupEditHelp = function() {
    var $edithelp = $('#edithelp');
    var $nav      = $('<div class="tab-nav"/>');
    var $close    = $('<a href="action://close" class="close-button"><span>X</span></a>');
    var tabs      = [];

    $edithelp.children('.syntax_help').each(function() {
        var $tab  = $(this);
        var $a    = $('<a/>');
        var title = $tab.children('h2:first').text();
        var id    = this.id;

        title = title.replace(/\s*\(.*/, '');

        $a.append(title).attr('href', "tab://" + title).click(function() {
            $.each(tabs, function() {
                this[0].removeClass('active');
                this[1].hide();
            });
            $tab.show();
            $a.addClass('active');
            return false;
        });

        tabs.push([$a, $tab]);
        $nav.append($a);
    });

    $close.click(function() { $edithelp.hide(); return false });

    tabs[0][0].click();
    $nav.append($close);
    $edithelp.prepend($nav);

    return tabs;
};
