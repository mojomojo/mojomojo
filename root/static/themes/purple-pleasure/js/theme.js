$(document).ready(function(){
	
    // Style Login Page different from the rest.
    if ( $('#loginField').size() ) {
        $("#content").css('overflow', 'visible');
        $("#content").css('width', 'auto');
        $("#content").css('-moz-border-radius-bottomleft', '20px');
        $("#content").css('-webkit-border-bottom-left-radius', '20px');
        $("#content").css('-moz-border-radius-bottomright', '20px');
        $("#content").css('-webkit-border-bottom-right-radius', '20px');
        $("#search_box").css('display', 'none');
        $("#bottomnav").css('display', 'none');
        $(".container").css('width', '30em');
		$(".container").css('height', '16em');
		$('fieldset').css('margin-left', '-6em');
		$('p').not(".logintext").css('float', 'right');
	$("#search_box").remove();
    }
});
