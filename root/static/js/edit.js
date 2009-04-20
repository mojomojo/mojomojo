$(document).ready(function() {
    if ($.cookies.get('split_edit')=='1'){
        split_layout_vertical();
    }
    $("#pageoptions").find("#split_edit_button").click(split_layout_vertical);

    toggleDefaultValue($("#authorName"));
    setupToggleMaximized();
});

setupToggleMaximized = function() {
    var $img         = $('<img id="maximize"/>');
    var is_maximized = $("#container").hasClass('maximized-container');

    // alt="[% loc ('maximize') %]"
    // title="[% loc('maximize width') %]"

    $img.click(function(toggle_width))
        .attr('src',
            is_maximized ? 'gfx/maximize_width_2.png'
          :                'gfx/maximize_width_1.png'
        ).hover(
            function() { this.src },
            function() { }
        );

    $("#breadcrumbs").append(
        $('<div class="float-right"/>').append($img)
    );
            

   $(document).ready(function() {
     $('#maximize').mouseover(function () {
       toggle_maximize_img($(this));
     });
     $('#maximize').mouseout(function () {
       toggle_maximize_img($(this));
     });
   }); 
     
   function toggle_maximize_img (img) {
     if (img.attr("src").match('maximize_width_1.png')){
       $('#maximize').attr("src", '[% c.uri_for_static('gfx/maximize_width_2.png') %]');
     } else {
       $('#maximize').attr("src", '[% c.uri_for_static('gfx/maximize_width_1.png') %]');
     }
   }

   function toggle_width() {
     var width;
     // first click on icon
     if ( typeof toggle_width.width == 'undefined' ) {
       // if maximized, get width from session variable
       if ( 1 == "[% c.session.maximize_width %]" ){
         toggle_width.width="[% c.session.container_default_width %]";
       } else {
         // get value from css
         toggle_width.width=$('#container').css('max-width');
         // store width
         $(this).load('[%c.uri_for('json/container_set_default_width/')%]'+toggle_width.width);
       }
     }
     // isn't maximized
     if ( $('#container').css('max-width')==toggle_width.width){
       $('#container').css('max-width','99%');
       // change icon
       $('#maximize').attr("src", '[% c.uri_for_static('gfx/maximize_width_1.png') %]');
       // set maximize
       $(this).load('[%c.uri_for('json/container_maximize_width/')%]'+toggle_width.width);
     } else {
       // toggle - restore default width
       $('#container').css('max-width',toggle_width.width);
       // change icon
       $('#maximize').attr("src", '[% c.uri_for_static('gfx/maximize_width_2.png') %]');
       // unset maximize
       $(this).load('[%c.uri_for('json/container_maximize_width/')%]');
     }
   }
});

toggleDefaultValue = function(elem) {
    elem.focus(function() {
            if(this.value == this.defaultValue) {
                this.value = "";
            }
        })
        .blur(function() {
            if(this.value == "") {
                this.value = this.defaultValue;
            }
        });
}

function split_layout_vertical() {
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
}
