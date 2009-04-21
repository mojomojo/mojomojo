$(document).ready(function() {
    if ($.cookies.get('split_edit')=='1'){
        split_layout_vertical();
    }
    $("#pageoptions").find("#split_edit_button").click(split_layout_vertical);

    toggleDefaultValue($("#authorName"));
    setupFormatterToolbar();
});

split_layout_vertical = function() {
    var max_container_width       = $(window).width();
    var preview_area_height       = '100%';
    var edit_area_height          = '40em';
    var preview_area_max_width    = max_container_width/2;
   
    if ($("div#edit_form").css('float')=='left'){
        $("div#edit_form").css('float',split_layout_vertical.deff);
        $("div#content_preview").css('float',split_layout_vertical.dcpf);
        $("div#content_preview").css('width',split_layout_vertical.dcpw);
        $("div#edit_form").css('width',split_layout_vertical.defw);
        $("div#container").css("max-width",split_layout_vertical.dcmw);
        $("div#header").css("background-repeat",split_layout_vertical.dhbr);
        $("div#preview").css("height",split_layout_vertical.dph);
        $("textarea#body").css("height",split_layout_vertical.tbh);
        //$("div.preview").css("max-width",split_layout_vertical.dpmw);
        $("div.preview").css("max-width",'100%');
		$.cookies.set('split_edit',0);
    } else {
        split_layout_vertical.deff=$('div#edit_form').css('float');
        split_layout_vertical.dcpf=$('div#content_preview').css('float');
        split_layout_vertical.dcpw=$('div#content_preview').css('width');
        split_layout_vertical.defw=$('div#edit_form').css('width');
        split_layout_vertical.dcmw=$('div#container').css('max-width');
        split_layout_vertical.dhbr=$('div#header').css('background-repeat');
        split_layout_vertical.dph=$('div.preview').css('height');
        split_layout_vertical.tbh=$('textarea#body').css('height');
        //split_layout_vertical.dpmw=$('div.preview').css('max-width');
        $("div#edit_form").css('float','left');
        $("div#content_preview").css('float','left');
        $("div#edit_form").css('width','49%');
        $("div#content_preview").css('width','49%');
        $("div#container").css("max-width", max_container_width);
        $("div#header").css('background-repeat', 'no-repeat');
        $("div.preview").css('height', preview_area_height);
        $("textarea#body").css('height', edit_area_height);
        $("div.preview").css('max-width', preview_area_max_width);
		$.cookies.set('split_edit',1);
    } 
};

_createToolbarSelect = function(id, options) {
    var $select = $('<select/>');

    $select.data('opt', options);
    $select.attr({ 'id': "toolbar_" + id.replace(/\s/g, "_"), 'title': _(id) });

    $select.append( $('<option>').append(_(id)) );

    $(options).each(function(i) {
        var text = options[i].shift();
        options[i].unshift('body'); // txtarea ID
        $select.append( $('<option>').val(i).append(_(text)) );
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
    $toolbar.append(_createToolbarSelect('Formatter', [
        [ 'IRC formatter', '\n{{irc}}\n',  '\n{{end}}\n\n',  '12:00 <nick> Hello #mojomojo!'],
        [ 'POD formatter', '\n{{pod}}\n\n','\n\n{{end}}\n\n',_("=head1 Header")]
    ]));

    // Insert 
    $toolbar.append(_createToolbarSelect('Insert', [
        [ 'comments', '\n{{comments}}\n','',''],
        [ 'toc', '\n{{toc}}','',''],
        [ 'redirect', '\n{{redirect ','}}','/new/location'],
        [ 'include', '\n{{','}}','http://www.google.com'],
        [ 'youtube', '\n{{youtube ','}}','http://www.youtube.com'],
        [ 'cpan', '\n{{cpan ','}}','MojoMojo']
    ]));

    // Syntax highlight
    $toolbar.append(_createToolbarSelect('Syntax Highlight', 
        $.map(syntax_formatters, function(n, i) {
            return [[ n, '\n\n{{code lang=\"' + n + '\"}}\n','\n{{end}}\n\n','#!/usr/bin/perl' ]];
        })
    ));

    $toolbar.append('<br>');

    // main or textile buttons
    if(wiki_type == 'main' || wiki_type == 'textile') {
        buttons = [
            [ 'heading', 'Main heading', '\n\nh1. ','\n\n',_('Also try h2,h3 and so on')],
            [ 'list_bullet', 'Bullet list', '\n\n* ','\n\n',_('List item 1')],
            [ 'list_enum', 'Enum list', '\n\n# ','\n\n',_('Numbered list item')],
            [ 'code', 'Code', '@','@',_('code')],
            [ 'quote', 'Block quote', 'bq. ','',_('quote')],
            [ 'left', 'Left-justified paragraph', '\n\np<. ','\n\n',_('left justified paragraph')],
            [ 'right', 'Right-justified paragraph', '\n\np>. ','\n\n',_('right justified paragraph')],
            [ 'center', 'Centered paragraph', '\n\np=. ','\n\n',_('centered paragraph')],
            [ 'justify', 'Justified paragraph', '\n\np<>. ','\n\n',_('justified paragraph')],
            [ 'bold', 'Bold', '*','*',_('bold')],
            [ 'italic', 'Italic', '_','_',_('italic')],
            [ 'strikethrough', 'Deleted Text', '-','-',_('deleted')],
            [ 'big', 'Bigger', '++','++',_('bigger')],
            [ 'small', 'Smaller', '--','--',_('small')],
            [ 'super', 'Superscript', '^','^',_('superscript')],
            [ 'sub', 'Subscript', '[~','~]',_('subscript')],
            [ 'wikilink', 'Internal Link', '[[',']]','/MojoMojo|Interwiki Link'],
            [ 'hyperlink', 'External Link', '&quot;','&quot;:/','link(hyper)'],
            [ 'drawing_left', 'Picture left', '<div class=photo>!<','!</div>','/.static/catalyst.png(Catalyst)'],
            [ 'drawing', 'Picture', '<div class=photo>!','!</div>','/.static/catalyst.png(Catalyst)'],
            [ 'drawing_right', 'Picture Right', '<div class=photo>!>','!</div>','/.static/catalyst.png(Catalyst)']
        ];
    }

    // markdown buttons
    else if(wiki_type = 'markdown') {
        buttons = [
            [ 'heading', 'Main heading', '\n\n# ',' #\n\n',_('increase # for smaller headline')],
            [ 'list_bullet', 'Bullet list', '\n\n* ','\n\n',_('List item 1')],
            [ 'list_enum', 'Enum list', '\n\n1 ','\n\n',_('Numbered list item')],
            [ 'bold', 'Bold', '**','**',_('bold')],
            [ 'italic', 'Italic', _('italic')],
            [ 'strikethrough', 'Deleted Text', '-','-',_('deleted')],
            [ 'wikilink', 'Internal Link', '[[',']]','/MojoMojo|Interwiki Link'],
            [ 'hyperlink', 'External Link', '[',']()',_('url inside paranthesis')],
            [ 'drawing_left', 'Picture left', '<div class=photo style=&quot;float: left&quot;>![alt text](', ' &quot;Title&quot;)</div>', '/.static/catalyst.png' ],
            [ 'drawing', 'Picture', '<div class=photo>![alt text](', ' &quot;Title&quot;)</div>', '/.static/catalyst.png' ],
            [ 'drawing_right', 'Picture Right', '<div class=photo style=&quot;float: right&quot;>![alt text](', ' &quot;Title&quot;)</div>', '/.static/catalyst.png' ]
        ];
    }

    // create and apply buttons
    $(buttons).each(function() {
        var data = this;
        var $button = $('<input type="image">');

        $button.attr({
            'src': $.uri_for('/.static/toolbar/' + data.shift() + '.png'),
            'title': _(data.shift())
        });

        data.unshift('body'); // txtarea ID
        $button.click(function() { return insertTags.apply(this, data); });
        $toolbar.append($button);
    });

    // help text
    $toolbar.append(
          '<br><small>&nbsp;'
        + _('Mark some text to apply the toolbar actions to that text')
        + '</small>'
    );
};

