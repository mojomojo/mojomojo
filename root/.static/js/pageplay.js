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





