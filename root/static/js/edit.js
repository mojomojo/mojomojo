/* Change the CSS and add a table to default edit mode to turn it 
 * into a side-by-side view/edit mode.
 */  
  
$(document).ready(function(){
	if ($("form#editForm")) {
		split_layout_vertical();
	}
});



// Hack up the edit layout into split mode using a two cell table.
function split_layout_vertical() {
    var max_container_width   = '1450px';
    var preview_area_height   = '100%';
    var edit_area_height      = '40em';
    
	// Set the dimension and banner for side-by-side preview/edit.
    var my_url = $.uri_for('/.static/gfx/header-long.png');
    my_url = 'url(' + my_url + ')';
    $("div#container").css("max-width", max_container_width);
    $("div#header").css('backgroundImage', my_url);
    $("div#header").css('background-repeat', 'no-repeat');
    $("div.preview").css('height', preview_area_height);
    //$("form#editForm").prepend("<input type='hidden' name='edit_split' value='1' id='edit_split' />");
    $("textarea#body").css('height', edit_area_height);

    // Put the preview and edit divs into a 1x2 table. 
    $("div#content_preview").wrap("<td id='preview_cell' width='50%'></td>");
    $("div#edit_form").wrap("<td id='edit_cell' width='50%'></td>");
    $("div#preview_and_edit_container").wrapInner('<table id="preview_and_edit_table" summary="holder for preview and edit areas" style="margin:auto; border:0px;"><tr></tr></table>');
    $("table#preview_and_edit_table > td").css('border', '0px');
    $("table#preview_and_edit_table").find("td").css('border','0px');

}


