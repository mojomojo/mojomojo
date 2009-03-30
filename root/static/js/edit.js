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
    } 
}
