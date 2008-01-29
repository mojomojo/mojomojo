function cleanAuthorName(author) {
  if (document.getElementById('authorName').value == "") {
    document.getElementById('authorName').value = author;
  }
}

function toggleInfo() {
    Element.toggle($('hidden_info'));
    return false;
}

function toggleChanges(changeurl) {
  if (!$('diff').innerHTML) {
      var req=new Ajax.Request( changeurl, {
      onComplete: function() {
	$('diff').innerHTML=req.transport.responseText;
        Element.toggle('changes');
        Element.toggle('current');
        Element.toggle('show_changes');
        Element.toggle('hide_changes');
      }});
  } else {
      Element.toggle('changes');
      Element.toggle('current');
      Element.toggle('show_changes');
      Element.toggle('hide_changes');
  }
}
function showdiff(changeurl,id) {
  if (!$('changes_'+id).innerHTML) {
      var req=new Ajax.Request( changeurl, {
      onComplete: function() {
          
	$('changes_'+id).innerHTML=req.transport.responseText;
      }});
  }
  Element.toggle('changes_'+id);
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
//
// copied and adapted from wikipedia, who
// copied and adapted from phpBB

function insertTags(txtarea,tagOpen, tagClose, sampleText) {

  txtarea = $(txtarea);
  // IE
  if(document.selection ) {
    var theSelection = document.selection.createRange().text;
    if(!theSelection) { theSelection=sampleText;}
    txtarea.focus();
    if(theSelection.charAt(theSelection.length - 1) == " "){// exclude ending space char, if any
      theSelection = theSelection.substring(0, theSelection.length - 1);
      document.selection.createRange().text = tagOpen + theSelection + tagClose + " ";
    } else {
      document.selection.createRange().text = tagOpen + theSelection + tagClose;
    }

  // DOM
  } else if(txtarea.selectionStart || txtarea.selectionStart == '0') {
    var startPos = txtarea.selectionStart;
    var endPos = txtarea.selectionEnd;
    var scrollTop=txtarea.scrollTop;
    var myText = (txtarea.value).substring(startPos, endPos);
    if(!myText) { myText=sampleText;}
    if(myText.charAt(myText.length - 1) == " "){ // exclude ending space char, if any
      subst = tagOpen + myText.substring(0, (myText.length - 1)) + tagClose + " ";
    } else {
      subst = tagOpen + myText + tagClose;
    }
    txtarea.value = txtarea.value.substring(0, startPos) + subst +
      txtarea.value.substring(endPos, txtarea.value.length);
    txtarea.focus();

    var cPos=startPos+(tagOpen.length+myText.length+tagClose.length);
    txtarea.selectionStart=cPos;
    txtarea.selectionEnd=cPos;
    txtarea.scrollTop=scrollTop;

  // All others
  } else {
    var copy_alertText=alertText;
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
}


