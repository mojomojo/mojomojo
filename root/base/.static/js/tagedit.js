/* tagedit - functions for editing tags. */

var dblClicked=0;
registerAction('taginput','focus',tagGetFocus);
registerAction('taginput','blur',tagBlur);
registerAction('taginput','keypress',submitenter);

var tags=document.getElementsBySelector('.tag')
for (i = 0; i != tags.length; i++) {
    registerAction(tags[i],'dblclick',handleWisely);
    registerAction(tags[i],'click',handleWisely);
}

function tagGetFocus() {
  gId('taginput').style.backgroundColor='CCCCCC';
}

function tagBlur() {
  gId('taginput').style.backgroundColor='999999';
}

function submitenter(event) {
    var keycode;
    keycode = event.keyCode;

    if (keycode == 13) {
        var url=base+'.jsrpc/tag/'+gId('taginput').value+'/'+node;
        gId('tags').innerHTML=xmlHTTPRequest(url);
        var tags=document.getElementsBySelector('.tag')
        for (i = 0; i != tags.length; i++) {
            registerAction(tags[i],'dblclick',handleWisely);
            registerAction(tags[i],'click',handleWisely);
        }
        gId('taginput').value='';
        return false;
   } else { return true; }
}


/* Code to handle clicks and doubleclick. */
 var dcTime=450;    // doubleclick time
 var dcDelay=450;   // no clicks after doubleclick
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
      dcAt = d.getTime();
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
        var tags=document.getElementsBySelector('.tag')
        for (i = 0; i != tags.length; i++) {
          registerAction(tags[i],'dblclick',handleWisely);
          registerAction(tags[i],'click',handleWisely);
        }
    } else {
        dblClicked=1;
        url= base+'.jsrpc/untag/'+tag.innerHTML+'/'+node;
        gId('tags').innerHTML=xmlHTTPRequest(url);
        gId('taginput').value=tag.innerHTML;
        var tags=document.getElementsBySelector('.tag')
        for (i = 0; i != tags.length; i++) {
            registerAction(tags[i],'dblclick',handleWisely);
            registerAction(tags[i],'click',handleWisely);
        }
    }
}

function goto_tag(event) {
 if (savEvtTime - dcAt <= 0) { return false; }
 document.location=base+'.recent/'+event.target.innerHTML;
}

