/* XMLHTTP functions 0.2 */
/* For all the Railsers out there */

/* Revisions */
/* 0.1 - 24 Jan 2005 - Written by Peter Cooper (coops) */
/* 0.2 - 26 Jan 2005 - ixXMLHTTPRequestSupported and success object checking supplied 
			by Jakob of http://Mentalized.net/ */

/* The licence is simple, use however you want, but leave attribution to any authors
   listed above, including yourself :-) */

function xmlHTTPRequest(url, method, data) {
  if (!method) method = "GET";
  if (!data) data = null;
  req = xmlHTTPRequestObject();
  if (req) {
	  req.open (method, url, false);
	  req.send (data);
	  return req.responseText;
  }
  return false;
}

function xmlHTTPAsyncRequest(url, method, data, callbackr) {
  if (!method) method = "GET";
  if (!data) data = null;
  req = xmlHTTPRequestObject();
  if (req) {
  	eval ('req.onreadystatechange = ' + callbackr + ';');
	req.open (method, url, true);
	req.send (data);
	return req
  }
}

function xmlHTTPRequestObject() {
	var obj = false;
	var objectIDs = new Array(
		"Microsoft.XMLHTTP",
		"Msxml2.XMLHTTP",
		"MSXML2.XMLHTTP.3.0",
		"MSXML2.XMLHTTP.4.0"
	);
	var success = false;

	for (i=0; !success && i < objectIDs.length; i++) {
		try {
			obj = new ActiveXObject(objectIDs[i]);
			success = true;
		} catch (e) { obj = false; }
	}

	if (!obj)
		obj = new XMLHttpRequest();

	return obj;
}

function isXMLHTTPRequestSupported() {
	return xmlHTTPRequestObject != null;
}
