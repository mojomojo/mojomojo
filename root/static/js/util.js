/* util.js - baseic utils for your ajax app */
/* Based on pageplay.js by Peter Cooper */
/* By Marcus Ramberg */

function registerAction(element,action,functionName) {
    if (typeof(element) == "string") { element=gId(element) }
    if (element) {
        try { 
            element.addEventListener($action, functionName, false);
        } catch(e) { }
        try { 
            element.attachEvent('on'+action, functionName, false);
        } catch(e) { 
          element['on'+action]=functionName;
        }
    }
}

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
    for (var i = 0; i < spans.length; i++) {
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
        document.getElementsByTagName = ie_getElementsByTagName;

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

var state=0;
    function toggleInfo() {
    state=!state;
    var item=gId('hidden_info');
    if (state) {
      item.style.display='block'; 
      item.style.opacity = 0.99999;
      item.style.filter = "alpha(opacity:"+100+")";
    } else {
      new Effect2.Fade('hidden_info')
    }
  }

