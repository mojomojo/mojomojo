/* pageplay - plays with elements on your page */
/* By Peter Cooper */

function toggleVisibility(id) {
   	if (document.getElementById(id).style.display == 'block') {
		document.getElementById(id).style.display = 'none'
    	} else {
		document.getElementById(id).style.display = 'block'
	}
}

function gId(id) {
	return document.getElementById(id)
}

function toggleVisibilityByClass(className) {
	spans = getElementsByClass(className);
	for (i = 0; i < spans.length; i++) {
	    if (spans[i].style.display == 'none') {
	      spans[i].style.display = 'inline';
	    } else {
	      spans[i].style.display = 'none';
	    }
	}
}

/* A hack to get IE5 (and IE4!) working */
function ie_getElementsByTagName(str) {
	if (str=="*")
		return document.all
	 else
		return document.all.tags(str)
}

function getElementsByClass(className) {
	if (document.all)
		document.getElementsByTagName = ie_getElementsByTagName

	var all = document.all ? document.all : document.getElementsByTagName("*");
	var elements = new Array();

	for (var e = 0; e < all.length; e++)
		if (all[e].className == className)
			elements[elements.length] = all[e];

	return elements;
}

function toggleCheckBox(id) {
	checkbox = gId(id)
	checkbox.checked = !checkbox.checked
}


/* Code to handle clicks and doubleclick. */
 var dcTime=250;    // doubleclick time
 var dcDelay=100;   // no clicks after doubleclick
 var dcAt=0;        // time of doubleclick
 var savEvent=null; // save Event for handling doClick().
 var savEvtTime=0;  // save time of click event.
 var savTO=null;    // handle of click setTimeOut
 
 function showMe(form, txt) {
   document.forms[form].elements[0].value += txt;
 }
 
function hadDoubleClick() {
  var d = new Date();
  var now = d.getTime();
  showMe(1, "Checking DC (" + now + " - " + dcAt);
  if ((now - dcAt) < dcDelay) {
    showMe(1, "*hadDC*");
    return true;
  }
  showMe(1, " OK ");
  return false;
}

function handleWisely(which) {
  showMe(1, which + " fired...");
  switch (which) {
    case "click": 
      // If we've just had a doubleclick then ignore it
      if (hadDoubleClick()) return false;
        
      // Otherwise set timer to act.  It may be preempted by a doubleclick.
      savEvent = which;
      d = new Date();
      savEvtTime = d.getTime();
      savTO = setTimeout("doClick(savEvent)", dcTime);
      break;
    case "dblclick":
      doDoubleClick(which);
      break;
    default:
  }
}

