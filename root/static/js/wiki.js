var uploader;
$( function() {
    $('.fade').each(function() { doBGFade(this,[255,255,100],[255,255,255],'transparent',75,20,4); })
    
    $('.toggleInfo').click(function() {
        $('#hidden_info').toggle();
        return false;
    });
    $('#body').attr({value: function() { this.value+append }})
    $('#body').each(function() { this.focus(); })
    $('#body').keyup(function() { fetch_preview.only_every(1000);});
    $('.activelink').click(function() { $(this).load($(this).attr('href')) ; return false })
    $('#add_tag').click(function(){$('#addtag').show();$('#showtag').hide();$('#taginput')[0].focus();return false;})
    $('#searchField').click(function() { this.value == 'Search' ? this.value = '' : true })
    $('.toggleChanges').click(function(){ toggleChanges($(this).attr('href'));return false;})
    $('#addtag_form').ajaxForm({
        target:'#tags',
        beforeSubmit: function() {
            $('#addtag').hide();
            $('#showtag').show();            
        },
        success: function() {
            $('#taginput').attr('value','')
        }
    })
    $('.tagaction').livequery('click', function() {
       $('#tags').load($(this).attr('href') );
       return false;
    }) 
    $('.diff_link').click(function() {
        target=$(this).parents('.item').find('.diff');
        if (!target.html()) {
            target.load( $(this).attr('href') );
        } 
        target.toggle();
        return false;
    })
   $('.image img').hover(function() {
        var info_url=$(this).parent().attr('href').replace(/.photo\//,'.jsrpc/imginfo/');
        $('#imageinfo').load(info_url)
    },function() {})
    $('#plain_upload').after('<a href="#" id="do_upload">Choose attachments</a>').hide()

	$('#do_upload').each(function() {
	    try {
	    uploader=new SWFUpload({
    		flash_url : '/.static/flash/swfupload_f9.swf',
    		upload_url: $('#upload_link').attr('href'),	// Relative to the SWF file
    		file_size_limit : "100 MB",
            file_post_name: 'file' ,
    		file_types : "*",
    		file_types_description : "Any files",
    		file_dialog_complete_handler : function(numFilesSelected, numFilesQueued) {
    		    this.startUpload();
    		},
    		upload_start_handler : function(file) {
                $('#progress').width('0')
                $('#progress_status').html(file.name+' 0% done');
                $('#progressbar').show();$('#progress_status').show();
    		    return true;
    		},
    		upload_progress_handler : function(file, bytesLoaded, bytesTotal) {
            	try {
            		var percent = Math.ceil((bytesLoaded / bytesTotal) * 100)+'%';
                    $('#progress').width(percent)
                    $('#progress_status').html(file.name+' '+percent+' done')
            	} catch (ex) {
            		this.debug(ex);
            	}		    
    		},
    		queue_complete_handler : function(numfiles) {
      		  $('#progressbar').hide();$('#progress_status').hide();
    		  $('#attachments').load($('#list_link').attr('href'))  
    		},
    		debug: false
    	})
	    } 
	    catch(ex) {
	        $('#plain_upload').show()
	    }
	}).click(function() { uploader.selectFiles() })
	$('.delete_attachment').click(function(){
	    link=$(this)
	    $.post(link.attr('href'),function(){
	        link.parents('p').remove();
	    })
	    return false;
	})
})

var fetch_preview = function() {
    jQuery.ajax({
      data: {content: $('#body').attr('value')},
      type: 'POST',
      url:  $('#preview_url').attr('href'),
      timeout: 2000,
      error: function() {
        console.log("Failed to submit");
      },
      success: function(r) { 
        $('#content_preview').html(r)
      }
    })
  }


function easeInOut(minValue,maxValue,totalSteps,actualStep,powr) {
	var delta = maxValue - minValue;
	var stepp = minValue+(Math.pow(((1 / totalSteps)*actualStep),powr)*delta);
	return Math.ceil(stepp)
}
	
function doBGFade(elem,startRGB,endRGB,finalColor,steps,intervals,powr) {
	if (elem.bgFadeInt) window.clearInterval(elem.bgFadeInt);
	var actStep = 0;
	elem.bgFadeInt = window.setInterval(
		function() {
			elem.style.backgroundColor = "rgb("+
				easeInOut(startRGB[0],endRGB[0],steps,actStep,powr)+","+
				easeInOut(startRGB[1],endRGB[1],steps,actStep,powr)+","+
				easeInOut(startRGB[2],endRGB[2],steps,actStep,powr)+")";
			actStep++;
			if (actStep > steps) {
			elem.style.backgroundColor = finalColor;
			window.clearInterval(elem.bgFadeInt);
			}
		}
		,intervals)
}


function cleanAuthorName(author) {
  if ($('#authorName').attr('value') == "") {
    $('#authorName').attr('value', author);
  }
}


function toggleChanges(changeurl) {
  if (!$('#diff').html()) {
      $('#diff').load( changeurl, function() {
        $('#changes').toggle();
        $('#current').toggle();
        $('#show_changes').toggle();
        $('#hide_changes').toggle();
      });
  } else {
      $('#changes').toggle();
      $('#current').toggle();
      $('#show_changes').toggle();
      $('#hide_changes').toggle();
  }
}


function encodeAjax (str) {
   str=str.replace(/%/g,'%25');
   str=str.replace(/&/g,'%26');
   str=str.replace(/\+/g,'%2b');
   str=str.replace(/\;/g,'%3b');
   return str;
}

// apply tagOpen/tagClose to selection in textarea,
// use sampleText instead of selection if there is none

function insertTags(txtarea,tagOpen, tagClose, sampleText) {

    txtarea = document.getElementById(txtarea);
    var theSelection;
    
    // IE / Opera
    if(document.selection  && document.selection.createRange) {
        theSelection = document.selection.createRange().text;
        if(!theSelection){ theSelection = sampleText; }
        txtarea.focus();
        if(theSelection.charAt(theSelection.length - 1) == " "){// exclude ending space char, if any
            theSelection = theSelection.substring(0, theSelection.length - 1);
            document.selection.createRange().text = tagOpen + theSelection + tagClose + " ";
        } else {
            document.selection.createRange().text = tagOpen + theSelection + tagClose;
        }

    // FireFox / Safari / Konqueror
    } else if (txtarea.selectionStart || txtarea.selectionStart == '0') { // Mozilla
        var startPos = txtarea.selectionStart;
        var endPos = txtarea.selectionEnd;
        var scrollTop=txtarea.scrollTop;
        theSelection = txtarea.value.substring(startPos, endPos);
        if(!theSelection){ theSelection = sampleText; }
        if(theSelection.charAt(theSelection.length - 1) == " "){ // exclude ending space char, if any
            subst = tagOpen + theSelection.substring(0, (theSelection.length - 1)) + tagClose + " ";
        } else {
            subst = tagOpen + theSelection + tagClose;
        }
        txtarea.value = txtarea.value.substring(0, startPos) + subst +
        txtarea.value.substring(endPos, txtarea.value.length);
        txtarea.focus();

        var cPos=startPos+(tagOpen.length+theSelection.length+tagClose.length);
        txtarea.selectionStart=cPos;
        txtarea.selectionEnd=cPos;
        txtarea.scrollTop=scrollTop;

        // All others ... such as?
    } else {
        var copy_alertText=sampleText;
        var re1=new RegExp("\\$1","g");
        var re2=new RegExp("\\$2","g");
        copy_alertText=copy_alertText.replace(re1,sampleText);
        copy_alertText=copy_alertText.replace(re2,tagOpen+sampleText+tagClose);
        var text;
        if (sampleText) {
            text=prompt(copy_alertText);
        } else {
            text="";
        }
        if(!text) { text=sampleText;}
        text=tagOpen+text+tagClose;
        document.infoform.infobox.value=text;
        // in Safari this causes scrolling
        if(!is_safari) {
            txtarea.focus();
        }
        noOverwrite=true;
    }
    // reposition cursor if possible
    if (txtarea.createTextRange) txtarea.caretPos = document.selection.createRange().duplicate();
    return false;
}

// Based on http://www.germanforblack.com/javascript-sleeping-keypress-delays-and-bashing-bad-articles
Function.prototype.only_every = function (millisecond_delay) {
  if (!window.only_every_func)
  {
    var function_object = this;
    window.only_every_func = setTimeout(function() { function_object(); window.only_every_func = null}, millisecond_delay);
   }
};

// jQuery extensions
jQuery.prototype.any = function(callback) { 
  return (this.filter(callback).length > 0)
}

