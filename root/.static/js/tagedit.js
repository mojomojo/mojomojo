/* tagedit - functions for editing tags. */

var taginput = gId('taginput');
if (taginput) {
    try { 
		  taginput.attachEvent("onfocus", tagGetFocus, false);
	} catch(e) { taginput.onfocus=tagGetFocus}
    try { 
		  taginput.attachEvent("onblur", tagBlur, false);
	} catch(e) { taginput.onblur=tagBlur}
    try { 
		  taginput.attachEvent("onkeypress", submitenter, false);
	} catch(e) { taginput.onkeypress=submitenter}
} 


var tags=document.getElementsBySelector('.tag')
for (i = 0; i != tags.length; i++) {
    try { 
              tags[i].attachEvent("ondblclick", handleWisely, false);
          } catch(e) { tags[i].ondblclick=handleWisely}
    try { 
              tags[i].attachEvent("onclick", handleWisely, false);
          } catch(e) { tags[i].onclick=handleWisely}
}

function tagGetFocus() {
  taginput.style.backgroundColor='CCCCCC';
}

function tagBlur() {
  taginput.style.backgroundColor='999999';
}

function submitenter(event) {
var keycode;
keycode = event.keyCode;

if (keycode == 13) {
   var url=base+'.jsrpc/tag/'+taginput.value+'/'+node;
   gId('tags').innerHTML=xmlHTTPRequest(url);
   taginput.value='';
   return false;
   } else { return true; }
}


/* Code to handle clicks and doubleclick. */
 var dcTime=450;    // doubleclick time
 var dcDelay=100;   // no clicks after doubleclick
 var dcAt=0;        // time of doubleclick
 var savEvent=null; // save Event for handling doClick().
 var savEvtTime=0;  // save time of click event.
 var savTO=null;    // handle of click setTimeOut
 
 
function hadDoubleClick() {
  var d = new Date();
  var now = d.getTime();
  if ((now - dcAt) < dcDelay) {
    return true;
  }
  return false;
}

function handleWisely(event) {
  var which=event.type;
  switch (which) {
    case "click": 
      // If we've just had a doubleclick then ignore it
      if (hadDoubleClick()) return false;
        
      // Otherwise set timer to act.  It may be preempted by a doubleclick.
      d = new Date();
      savEvent=event;
      savTO = setTimeout("goto_tag(savEvent)", dcTime);
      break;
    case "dblclick":
      mark_tag(event);
      break;
    default:
  }
}


function mark_tag(event) {
 var tag=event.target;
 if (tag.title) {
   url=base+'.jsrpc/tag/'+tag.innerHTML+'/'+node;
   gId('tags').innerHTML=xmlHTTPRequest(url)
 } else {
   gId('taginput').value=tag.innerHTML;
   url= base+'.jsrpc/untag/'+tag.innerHTML+'/'+node;
   gId('tags').innerHTML=xmlHTTPRequest(url);
 }
}

function goto_tag(event) {
 document.location=base+'.recent/'+event.target.innerHTML;
}

