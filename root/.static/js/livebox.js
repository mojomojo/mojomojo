var liveboxwas = '';  
var liveboxstatus = 0;
var liveboxid = '';
var liveboxUrl = '';
var liveboxOutput = '';
var p;

function liveBox(id,output) {
    liveboxOutput=output;
    liveboxid = id;
    registerAction(id,"focus",liveBoxStart);
    registerAction(id,"blur",liveBoxEnd);
}

function setLiveboxUrl(url) {
	liveboxUrl=url;
}

function liveBoxStart() {
        liveboxstatus = 1;
        liveBoxDo();
}

function liveBoxEnd() {
        liveboxstatus = 0;
}

function doStuff() {
	if (req.readyState == 4 && req.status != 200) {
		/* We get here if an error occurs, like a 403, 404, 500, etc */
		/* p.statusText will hold a human readable answer, or use p.status */
		gId(liveboxOutput).innerHTML = req.statusText;
    return;
	}
        if (req.readyState == 4 && req.status == 200) {
		/* We get here if things went well */
		gId(liveboxOutput).innerHTML = req.responseText;
	}
}

function liveBoxDo() {
        if (liveboxstatus == 1) {
                setTimeout('liveBoxDo()', 1200);
        }
        if (gId(liveboxid).value != liveboxwas) {
          liveboxwas = gId(liveboxid).value;
          p = xmlHTTPAsyncRequest(liveboxUrl, 'POST' ,'content='+liveboxwas ,'doStuff');
        }
}
