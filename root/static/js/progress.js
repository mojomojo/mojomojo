
var progress;

function startPopupProgressBar(form, options) {
    var id = generateProgressID();
    if (form.action.match(/\?/))
        form.action += '&progress_id=' + id;
    else
        form.action += '?progress_id=' + id;

    var width  = options.width  || '480';
    var height = options.height || '150';
    window.open ('progress?progress_id='+id,'Apache2-UploadProgress','location=0,status=0,width='+width+',height='+height); return true;


}

function startEmbeddedProgressBar(form) {
    progress = {};
    progress.id         = generateProgressID();
    if (form.action.match(/\?/))
        form.action += '&progress_id=' + progress.id;
    else
        form.action += '?progress_id=' + progress.id;
    progress.starttime  = new Date();
    progress.lasttime   = new Date(progress.starttime);
    progress.lastamount = 0;
    window.setTimeout( reportUploadProgress, 100 );
    return true;
}

function updateHTMLProgressBar(progress) {
    if (progress.size > progress.received)
        window.setTimeout( function() { window.location.reload() }, 1000 );
    updateProgressBar( progress );
    return true;
}

function updateProgressBar(progress) {

    if (progress.received == progress.size)
        progress.finished = 1;

    // Only calculate rates and times is we were given a starttime
    if (progress.starttime) {
        var currenttime = new Date();
        var totalelapsedtime = ( currenttime.getTime() - progress.starttime.getTime() ) / 1000;
        var lastelapsedtime  = ( currenttime.getTime() - progress.lasttime.getTime() ) / 1000;

        progress.elapsedtime = totalelapsedtime;

        if (totalelapsedtime != 0)
            progress.rate = parseInt( progress.received / totalelapsedtime );
        else
            progress.rate = 0;

        if (lastelapsedtime != 0)
            progress.currentrate = parseInt( (progress.received - progress.lastamount) / lastelapsedtime );
        else
            progress.currentrate = 0

        if (progress.currentrate != 0)
            progress.remainingtime = parseInt( (progress.size - progress.received) / progress.rate );
        else
            progress.remainingtime = '';

        progress.currentrate   = formatBytes(progress.currentrate);
        progress.rate          = formatBytes(progress.rate);
        progress.elapsedtime   = formatTime(progress.elapsedtime);
        progress.remainingtime = formatTime(progress.remainingtime);
    }

    if (progress.size != 0)
        progress.percent = Math.round(progress.received / progress.size * 100);

    progress.size     = formatBytes(progress.size);
    progress.received = formatBytes(progress.received);

    document.getElementById('progress').innerHTML = Jemplate.process('progress.jmpl', progress);
}

function reportUploadProgress() {
    
    url = 'progress?progress_id=' + progress.id;

    var req = new XMLHttpRequest();
    req.open('GET', url, Boolean(handleUploadProgressResults));
    // We have to set the qvalue to 1.1 because Konqueror sends
    // it's standard Accept header with our header tacked on the end
    // which means that text/html gets picked first
    req.setRequestHeader(
        'Accept', 
        'text/x-json; q=1.1'
    );
    req.onreadystatechange = function() {
        if (req.readyState == 4)
            if (req.status == 200)
                handleUploadProgressResults(req.responseText);
            else
                // If there was an error, try again in 4 seconds
                window.setTimeout( reportUploadProgress, 4000 );
    };
    req.send(null);
}

function handleUploadProgressResults(results) {

    var state = JSON.parse(results);

    if ( state != undefined ) {

        state.starttime       = progress.starttime;
        state.lasttime        = progress.lasttime;
        state.lastamount      = progress.lastamount;

        progress.lasttime     = new Date();
        progress.lastamount   = state.received;
        progress.size         = state.size;
        progress.received     = state.received;

        if ( progress.received != progress.size && !state.aborted ) {
            window.setTimeout( reportUploadProgress, 1000 );
        }

        updateProgressBar(state);
    }
}

function formatTime(time) {
    var seconds = Math.round(time);
    var minutes = 0;
    if (time >= 60) {
        minutes = Math.round(seconds / 60);
        seconds %= 60;
    }
    if (seconds < 10)
        seconds = '0' + seconds;

    return minutes + ':' + seconds;
}

function formatBytes(bytes, precision) {
    if ( typeof(precision) != 'number')
        precision = 2;
    var suffix = '';

    // Only positive values are allowed
    if (bytes <= 0)
        return bytes;

    if (bytes > 1073741824) {
        bytes /= 1073741824;
        suffix = 'G';
    } else if (bytes > 1048576) {
        bytes /= 1048576;
        suffix = 'M';
    } else if (bytes > 1024) {
        bytes /= 1024;
        suffix = 'K';
    }

    return formatNumber(bytes, precision) + suffix;
}

function formatNumber(number, precision) {
    if ( typeof(precision) != 'number')
        precision = 2;
    var num = new Number(number);
    return num.toFixed(precision)
}

function setActiveStyleSheet(title) {
    var i, a, main;
    for(i=0; (a = document.getElementsByTagName("link")[i]); i++) {
        if(a.getAttribute("rel").indexOf("style") != -1 && a.getAttribute("title")) {
            a.disabled = true;
            if(a.getAttribute("title") == title)
                 a.disabled = false;
        }
    }
}

var alpha = "0123456789abcdef";

function generateProgressID() {
    var id = '';
    for(var i=0; i < 32; i++) {
        id += alpha.charAt(Math.round(Math.random()*14));
    }
    return id;
}


/*------------------------------------------------------------------------------
Jemplate - Template Toolkit for Javascript

DESCRIPTION - This module provides the runtime Javascript support for
compiled Jemplate templates.

AUTHOR - Ingy döt Net <ingy@cpan.org>

Copyright 2006 Ingy döt Net. All Rights Reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.
------------------------------------------------------------------------------*/

//------------------------------------------------------------------------------
// Main Jemplate class
//------------------------------------------------------------------------------
if (typeof Jemplate == 'undefined')
    Jemplate = function() {};

Jemplate.templateMap = {};

Jemplate.process = function(template, data, output) {
    var context = new Jemplate.Context();
    context.stash = new Jemplate.Stash();
    context._filter = new Jemplate.Filter();
    var result;

    var proc = function(input) {
        try { 
            result = context.process(template, input);
        }
        catch(e) {
            if (! String(e).match(/Jemplate\.STOP\n/))
                throw(e);
            result = e.toString().replace(/Jemplate\.STOP\n/, '')
        }

        if (typeof output == 'undefined')
            return result;
        if (typeof output == 'function') {
            output(result);
            return;
        }
        if (typeof(output) == 'string' || output instanceof String) {
            if (output.match(/^#[\w\-]+$/)) {
                var id = output.replace(/^#/, '');
                var element = document.getElementById(id);
                if (typeof element == 'undefined')
                    throw('No element found with id="' + id + '"');
                element.innerHTML = result;
                return;
            }
        }
        else {
            output.innerHTML = result;
            return;
        }

        throw("Invalid arguments in call to Jemplate.process");

        return 1;
    }

    if (typeof data == 'function')
        data = data();
    else if (typeof data == 'string') {
        Ajax.get(data, function(r) { proc(JSON.parse(r)) });
        return;
    }

    return proc(data);
}

//------------------------------------------------------------------------------
// Jemplate.Context class
//------------------------------------------------------------------------------
if (typeof Jemplate.Context == 'undefined')
    Jemplate.Context = function() {};

proto = Jemplate.Context.prototype;

proto.include = function(template, args) {
    return this.process(template, args, true);
}

proto.process = function(template, args, localise) {
    if (localise)
        this.stash.clone(args);
    else
        this.stash.update(args);
    var func = Jemplate.templateMap[template];
    if (typeof func == 'undefined')
        throw('No Jemplate template named "' + template + '" available');
    var output = func(this);
    if (localise)
        this.stash.declone();
    return output;
}

proto.set_error = function(error, output) {
    this._error = [error, output];
    return error;
}

proto.filter = function(text, name, args) {
    if (name == 'null') 
        name = "null_filter";
    if (typeof this._filter.filters[name] == "function")
        return this._filter.filters[name](text, args, this);  
    else 
        throw "Unknown filter name ':" + name + "'";
}

//------------------------------------------------------------------------------
// Jemplate.Filter class
//------------------------------------------------------------------------------
if (typeof Jemplate.Filter == 'undefined') {
    Jemplate.Filter = function() { };
}

proto = Jemplate.Filter.prototype;

proto.filters = {};

proto.filters.null_filter = function(text) {
    return ''; 
}

proto.filters.upper = function(text) {
    return text.toUpperCase();
}

proto.filters.lower = function(text) {
    return text.toLowerCase();
}

proto.filters.ucfirst = function(text) {
    var first = text.charAt(0);
    var rest = text.substr(1);
    return first.toUpperCase() + rest;
}

proto.filters.lcfirst = function(text) {
    var first = text.charAt(0);
    var rest = text.substr(1);
    return first.toLowerCase() + rest;
}

proto.filters.trim = function(text) {
    return text.replace( /^\s+/g, "" ).replace( /\s+$/g, "" );
}

proto.filters.collapse = function(text) {
    return text.replace( /^\s+/g, "" ).replace( /\s+$/g, "" ).replace(/\s+/, " ");
}

proto.filters.html = function(text) {
    text = text.replace(/&/g, '&amp;'); 
    text = text.replace(/</g, '&lt;');
    text = text.replace(/>/g, '&gt;');
    text = text.replace(/"/g, '&quot;'); // " end quote for emacs
    return text;
}

proto.filters.html_para = function(text) {
    var lines = text.split(/(?:\r?\n){2,}/);
    return "<p>\n" + lines.join("\n</p>\n\n<p>\n") + "</p>\n";
}

proto.filters.html_break = function(text) {
    return text.replace(/(\r?\n){2,}/g, "$1<br />$1<br />$1");
}

proto.filters.html_line_break = function(text) {
    return text.replace(/(\r?\n)/g, "$1<br />$1");
}

proto.filters.uri = function(text) {
    return encodeURI(text);
}

proto.filters.indent = function(text, args) {
    var pad = args[0];
    if (! text) return;
    if (typeof pad == 'undefined') 
        pad = 4;

    var finalpad = '';
    if (typeof pad == 'number' || String(pad).match(/^\d$/)) {
        for (var i = 0; i < pad; i++) {
            finalpad += ' '; 
        }
    } else {
        finalpad = pad;
    }
    var output = text.replace(/^/gm, finalpad);
    return output;
}

proto.filters.truncate = function(text, args) {
    var len = args[0];
    if (! text) return;
    if (! len) 
        len = 32;
    // This should probably be <=, but TT just uses <
    if (text.length < len)
        return text;
    var newlen = len - 3;
    return text.substr(0,newlen) + '...';
}

proto.filters.repeat = function(text, iter) {
    if (! text) return;
    if (! iter || iter == 0) 
        iter = 1;
    if (iter == 1) return text
    
    var output = text;
    for (var i = 1; i < iter; i++) {
        output += text;
    } 
    return output;
}

proto.filters.replace = function(text, args) {
    if (! text) return;
    var re_search = args[0];
    var text_replace = args[1];
    if (! re_search)
        re_search = '';
    if (! text_replace)
        text_replace = '';
    var re = new RegExp(re_search, 'g');
    return text.replace(re, text_replace);
}

//------------------------------------------------------------------------------
// Jemplate.Stash class
//------------------------------------------------------------------------------
if (typeof Jemplate.Stash == 'undefined') {
    Jemplate.Stash = function() {
        this.data = {};
    };
}

proto = Jemplate.Stash.prototype;

proto.clone = function(args) {
    var data = this.data;
    this.data = {};
    this.update(data);
    this.update(args);
    this.data._PARENT = data;
}

proto.declone = function(args) {
    this.data = this.data._PARENT || this.data;
}

proto.update = function(args) {
    if (typeof args == 'undefined') return;
    for (var key in args) {
        var value = args[key];
        this.set(key, value);
    }
}

proto.get = function(key) {
    var root = this.data;
    if (key instanceof Array) {
        for (var i = 0; i < key.length; i += 2) {
            var args = key.slice(i, i+2);
            args.unshift(root);
            value = this._dotop.apply(this, args);
            if (typeof value == 'undefined')
                break;
            root = value;
    
    }
    }
    else {
        value = this._dotop(root, key);
    }

    return value;
}

proto.set = function(key, value, set_default) {
    if (! (set_default && (typeof this.data[key] != 'undefined')))
        this.data[key] = value;
}

proto._dotop = function(root, item, args) {
    if (typeof item == 'undefined' ||
        typeof item == 'string' && item.match(/^[\._]/)) {
        return undefined;
    }

    if ((! args) &&
        (typeof root == 'object') &&
        (!(root instanceof Array) || (typeof item == 'number')) &&
        (typeof root[item] != 'undefined')) {
        var value = root[item];
        if (typeof value == 'function')
            value = value();
        return value;
    }

    if (typeof root == 'string' && this.string_functions[item])
        return this.string_functions[item](root, args);
    if (root instanceof Array && this.list_functions[item])
        return this.list_functions[item](root, args);
    if (typeof root == 'object' && this.hash_functions[item])
        return this.hash_functions[item](root, args);
    if (typeof root[item] == 'function')
        return root[item].apply(args);

    return undefined;
}

proto.string_functions = {};

// chunk(size)     negative size chunks from end 
proto.string_functions.chunk = function(string, args) {
    var size = args[0];
    var list = new Array();
    if (! size)
        size = 1;
    if (size < 0) {
        size = 0 - size;
        for (i = string.length - size; i >= 0; i = i - size)
            list.unshift(string.substr(i, size));
        if (string.length % size)
            list.unshift(string.substr(0, string.length % size));
    }
    else
        for (i = 0; i < string.length; i = i + size)
            list.push(string.substr(i, size));
    return list;
}

// defined         is value defined? 
proto.string_functions.defined = function(string) {
    return 1;
}

// hash            treat as single-element hash with key value 
proto.string_functions.hash = function(string) {
    return { 'value': string };
}

// length          length of string representation 
proto.string_functions.length = function(string) {
    return string.length;
}

// list            treat as single-item list 
proto.string_functions.list = function(string) {
    return [ string ];
}

// match(re)       get list of matches
proto.string_functions.match = function(string, args) {
    var regexp = new RegExp(args[0], 'gm');
    var list = string.match(regexp);
    return list;
}

// repeat(n)       repeated n times 
proto.string_functions.repeat = function(string, args) {
    var n = args[0] || 1;
    var output = '';
    for (var i = 0; i < n; i++) {
        output += string;
    }
    return output;
}

// replace(re, sub)    replace instances of re with sub 
proto.string_functions.replace = function(string, args) {
    var regexp = new RegExp(args[0], 'gm');
    var sub = args[1];
    if (! sub)
        sub  = '';
    var output = string.replace(regexp, sub);
    return output;
}

// search(re)      true if value matches re
proto.string_functions.search = function(string, args) {
    var regexp = new RegExp(args[0]);
    return (string.search(regexp) >= 0) ? 1 : 0;
}

// size            returns 1, as if a single-item list 
proto.string_functions.size = function(string) {
    return 1;
}

// split(re)       split string on re 
proto.string_functions.split = function(string, args) {
    var regexp = new RegExp(args[0]);
    var list = string.split(regexp);
    return list;
}



proto.list_functions = {};

proto.list_functions.join = function(list, args) {
    return list.join(args[0]);
};

proto.list_functions.sort = function(list) {
    return list.sort();
}

proto.list_functions.nsort = function(list) {
    return list.sort(function(a, b) { return (a-b) });
}

proto.list_functions.grep = function(list, args) {
    var regexp = new RegExp(args[0]);
    var result = [];
    for (var i = 0; i < list.length; i++) {
        if (list[i].match(regexp))
            result.push(list[i]);
    }
    return result;
}

proto.list_functions.unique = function(list) {
    var result = [];
    var seen = {};
    for (var i = 0; i < list.length; i++) {
        var elem = list[i];
        if (! seen[elem])
            result.push(elem);
        seen[elem] = true;
    }
    return result;
}

proto.list_functions.reverse = function(list) {
    var result = [];
    for (var i = list.length - 1; i >= 0; i--) {
        result.push(list[i]);
    }
    return result;
}

proto.list_functions.merge = function(list, args) {
    var result = [];
    var push_all = function(elem) {
        if (elem instanceof Array) {
            for (var j = 0; j < elem.length; j++) {
                result.push(elem[j]);
            }
        }
        else {
            result.push(elem);
        }
    }
    push_all(list);
    for (var i = 0; i < args.length; i++) {
        push_all(args[i]);
    }
    return result;
}

proto.list_functions.slice = function(list, args) {
    return list.slice(args[0], args[1]);
}

proto.list_functions.splice = function(list, args) {
    if (args.length == 1)
        return list.splice(args[0]);
    if (args.length == 2)
        return list.splice(args[0], args[1]);
    if (args.length == 3)
        return list.splice(args[0], args[1], args[2]);
}

proto.list_functions.push = function(list, args) {
    list.push(args[0]);
    return list;        
}

proto.list_functions.pop = function(list) {
    return list.pop();
}

proto.list_functions.unshift = function(list, args) {
    list.unshift(args[0]);
    return list;        
}

proto.list_functions.shift = function(list) {
    return list.shift();
}

proto.list_functions.first = function(list) {
    return list[0];        
}

proto.list_functions.size = function(list) {
    return list.length;
}

proto.list_functions.max = function(list) {
    return list.length - 1;
}

proto.list_functions.last = function(list) {
    return list.slice(-1);        
}

proto.hash_functions = {};


// each            list of alternating keys/values 
proto.hash_functions.each = function(hash) {
    var list = new Array();
    for ( var key in hash )
        list.push(key, hash[key]);
    return list;
}

// exists(key)     does key exist? 
proto.hash_functions.exists = function(hash, args) {
    return ( typeof( hash[args[0]] ) == "undefined" ) ? 0 : 1;
}

// FIXME proto.hash_functions.import blows everything up
//
// import(hash2)   import contents of hash2 
// import          import into current namespace hash 
//proto.hash_functions.import = function(hash, args) {
//    var hash2 = args[0];
//    for ( var key in hash2 )
//        hash[key] = hash2[key];
//    return '';
//}

// keys            list of keys 
proto.hash_functions.keys = function(hash) {
    var list = new Array();
    for ( var key in hash )
        list.push(key);
    return list;
}

// list            returns alternating key, value 
proto.hash_functions.list = function(hash, args) {
    var what = '';
    if ( args )
        var what = args[0];
        
    var list = new Array();
    if (what == 'keys')
        for ( var key in hash )
            list.push(key);
    else if (what == 'values')
        for ( var key in hash )
            list.push(hash[key]);
    else if (what == 'each')
        for ( var key in hash )
            list.push(key, hash[key]);
    else
        for ( var key in hash )
            list.push({ 'key': key, 'value': hash[key] });

    return list;
}

// nsort           keys sorted numerically 
proto.hash_functions.nsort = function(hash) {
    var list = new Array();
    for (var key in hash)
        list.push(key);
    return list.sort(function(a, b) { return (a-b) });
}

// size            number of pairs 
proto.hash_functions.size = function(hash) {
    var size = 0;
    for (var key in hash)
        size++;
    return size;
}


// sort            keys sorted alphabetically 
proto.hash_functions.sort = function(hash) {
    var list = new Array();
    for (var key in hash)
        list.push(key);
    return list.sort();
}

// values          list of values 
proto.hash_functions.values = function(hash) {
    var list = new Array();
    for ( var key in hash )
        list.push(hash[key]);
    return list;
}



//------------------------------------------------------------------------------
// Jemplate.Iterator class
//------------------------------------------------------------------------------
if (typeof Jemplate.Iterator == 'undefined') {
    Jemplate.Iterator = function(object) {
        if( object instanceof Array ) {
            this.object = object;
        }
        else if ( object instanceof Object ) {
            this.object = object;
            var object_keys = new Array;
            for( var key in object ) {
                object_keys[object_keys.length] = key;
            }
            this.object_keys = object_keys.sort();
        }
    }
}

proto = Jemplate.Iterator.prototype;

proto.get_first = function() {
    this.index = 0;
    return this.get_next();
}

proto.get_next = function() {
    var object = this.object;
    var index = this.index++;
    if (typeof object == 'undefined')
        throw('No object to iterate');
    if( this.object_keys ) {
        if (index < this.object_keys.length)
            return [this.object_keys[index], false];
    } else {
        if (index < object.length)
            return [object[index], false];
    }
    return [null, true];
}

//------------------------------------------------------------------------------
// Debugging Support
//------------------------------------------------------------------------------

function XXX(msg) {
    if (! confirm(msg))
        throw("terminated...");
}

function JJJ(obj) {
    XXX(JSON.stringify(obj));
}

//------------------------------------------------------------------------------
// Ajax support
//------------------------------------------------------------------------------
if (! this.Ajax) Ajax = {};

Ajax.get = function(url, callback) {
    var req = new XMLHttpRequest();
    req.open('GET', url, Boolean(callback));
    return Ajax._send(req, null, callback);
}

Ajax.post = function(url, data, callback) {
    var req = new XMLHttpRequest();
    req.open('POST', url, Boolean(callback));
    req.setRequestHeader(
        'Content-Type', 
        'application/x-www-form-urlencoded'
    );
    return Ajax._send(req, data, callback);
}

Ajax._send = function(req, data, callback) {
    if (callback) {
        req.onreadystatechange = function() {
            if (req.readyState == 4) {
                if(req.status == 200)
                    callback(req.responseText);
            }
        };
    }
    req.send(data);
    if (!callback) {
        if (req.status != 200)
            throw('Request for "' + url +
                  '" failed with status: ' + req.status);
        return req.responseText;
    }
}

//------------------------------------------------------------------------------
// Cross-Browser XMLHttpRequest v1.1
//------------------------------------------------------------------------------
/*
Emulate Gecko 'XMLHttpRequest()' functionality in IE and Opera. Opera requires
the Sun Java Runtime Environment <http://www.java.com/>.

by Andrew Gregory
http://www.scss.com.au/family/andrew/webdesign/xmlhttprequest/

This work is licensed under the Creative Commons Attribution License. To view a
copy of this license, visit http://creativecommons.org/licenses/by/1.0/ or send
a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305,
USA.
*/

// IE support
if (window.ActiveXObject && !window.XMLHttpRequest) {
  window.XMLHttpRequest = function() {
    return new ActiveXObject((navigator.userAgent.toLowerCase().indexOf('msie 5') != -1) ? 'Microsoft.XMLHTTP' : 'Msxml2.XMLHTTP');
  };
}

// Opera support
if (window.opera && !window.XMLHttpRequest) {
  window.XMLHttpRequest = function() {
    this.readyState = 0; // 0=uninitialized,1=loading,2=loaded,3=interactive,4=complete
    this.status = 0; // HTTP status codes
    this.statusText = '';
    this._headers = [];
    this._aborted = false;
    this._async = true;
    this.abort = function() {
      this._aborted = true;
    };
    this.getAllResponseHeaders = function() {
      return this.getAllResponseHeader('*');
    };
    this.getAllResponseHeader = function(header) {
      var ret = '';
      for (var i = 0; i < this._headers.length; i++) {
        if (header == '*' || this._headers[i].h == header) {
          ret += this._headers[i].h + ': ' + this._headers[i].v + '\n';
        }
      }
      return ret;
    };
    this.setRequestHeader = function(header, value) {
      this._headers[this._headers.length] = {h:header, v:value};
    };
    this.open = function(method, url, async, user, password) {
      this.method = method;
      this.url = url;
      this._async = true;
      this._aborted = false;
      if (arguments.length >= 3) {
        this._async = async;
      }
      if (arguments.length > 3) {
        // user/password support requires a custom Authenticator class
        opera.postError('XMLHttpRequest.open() - user/password not supported');
      }
      this._headers = [];
      this.readyState = 1;
      if (this.onreadystatechange) {
        this.onreadystatechange();
      }
    };
    this.send = function(data) {
      if (!navigator.javaEnabled()) {
        alert("XMLHttpRequest.send() - Java must be installed and enabled.");
        return;
      }
      if (this._async) {
        setTimeout(this._sendasync, 0, this, data);
        // this is not really asynchronous and won't execute until the current
        // execution context ends
      } else {
        this._sendsync(data);
      }
    }
    this._sendasync = function(req, data) {
      if (!req._aborted) {
        req._sendsync(data);
      }
    };
    this._sendsync = function(data) {
      this.readyState = 2;
      if (this.onreadystatechange) {
        this.onreadystatechange();
      }
      // open connection
      var url = new java.net.URL(new java.net.URL(window.location.href), this.url);
      var conn = url.openConnection();
      for (var i = 0; i < this._headers.length; i++) {
        conn.setRequestProperty(this._headers[i].h, this._headers[i].v);
      }
      this._headers = [];
      if (this.method == 'POST') {
        // POST data
        conn.setDoOutput(true);
        var wr = new java.io.OutputStreamWriter(conn.getOutputStream());
        wr.write(data);
        wr.flush();
        wr.close();
      }
      // read response headers
      // NOTE: the getHeaderField() methods always return nulls for me :(
      var gotContentEncoding = false;
      var gotContentLength = false;
      var gotContentType = false;
      var gotDate = false;
      var gotExpiration = false;
      var gotLastModified = false;
      for (var i = 0; ; i++) {
        var hdrName = conn.getHeaderFieldKey(i);
        var hdrValue = conn.getHeaderField(i);
        if (hdrName == null && hdrValue == null) {
          break;
        }
        if (hdrName != null) {
          this._headers[this._headers.length] = {h:hdrName, v:hdrValue};
          switch (hdrName.toLowerCase()) {
            case 'content-encoding': gotContentEncoding = true; break;
            case 'content-length'  : gotContentLength   = true; break;
            case 'content-type'    : gotContentType     = true; break;
            case 'date'            : gotDate            = true; break;
            case 'expires'         : gotExpiration      = true; break;
            case 'last-modified'   : gotLastModified    = true; break;
          }
        }
      }
      // try to fill in any missing header information
      var val;
      val = conn.getContentEncoding();
      if (val != null && !gotContentEncoding) this._headers[this._headers.length] = {h:'Content-encoding', v:val};
      val = conn.getContentLength();
      if (val != -1 && !gotContentLength) this._headers[this._headers.length] = {h:'Content-length', v:val};
      val = conn.getContentType();
      if (val != null && !gotContentType) this._headers[this._headers.length] = {h:'Content-type', v:val};
      val = conn.getDate();
      if (val != 0 && !gotDate) this._headers[this._headers.length] = {h:'Date', v:(new Date(val)).toUTCString()};
      val = conn.getExpiration();
      if (val != 0 && !gotExpiration) this._headers[this._headers.length] = {h:'Expires', v:(new Date(val)).toUTCString()};
      val = conn.getLastModified();
      if (val != 0 && !gotLastModified) this._headers[this._headers.length] = {h:'Last-modified', v:(new Date(val)).toUTCString()};
      // read response data
      var reqdata = '';
      var stream = conn.getInputStream();
      if (stream) {
        var reader = new java.io.BufferedReader(new java.io.InputStreamReader(stream));
        var line;
        while ((line = reader.readLine()) != null) {
          if (this.readyState == 2) {
            this.readyState = 3;
            if (this.onreadystatechange) {
              this.onreadystatechange();
            }
          }
          reqdata += line + '\n';
        }
        reader.close();
        this.status = 200;
        this.statusText = 'OK';
        this.responseText = reqdata;
        this.readyState = 4;
        if (this.onreadystatechange) {
          this.onreadystatechange();
        }
        if (this.onload) {
          this.onload();
        }
      } else {
        // error
        this.status = 404;
        this.statusText = 'Not Found';
        this.responseText = '';
        this.readyState = 4;
        if (this.onreadystatechange) {
          this.onreadystatechange();
        }
        if (this.onerror) {
          this.onerror();
        }
      }
    };
  };
}
// ActiveXObject emulation
if (!window.ActiveXObject && window.XMLHttpRequest) {
  window.ActiveXObject = function(type) {
    switch (type.toLowerCase()) {
      case 'microsoft.xmlhttp':
      case 'msxml2.xmlhttp':
        return new XMLHttpRequest();
    }
    return null;
  };
}


//------------------------------------------------------------------------------
// JSON Support
//------------------------------------------------------------------------------

/*
Copyright (c) 2005 JSON.org
*/
var JSON = function () {
    var m = {
            '\b': '\\b',
            '\t': '\\t',
            '\n': '\\n',
            '\f': '\\f',
            '\r': '\\r',
            '"' : '\\"',
            '\\': '\\\\'
        },
        s = {
            'boolean': function (x) {
                return String(x);
            },
            number: function (x) {
                return isFinite(x) ? String(x) : 'null';
            },
            string: function (x) {
                if (/["\\\x00-\x1f]/.test(x)) {
                    x = x.replace(/([\x00-\x1f\\"])/g, function(a, b) {
                        var c = m[b];
                        if (c) {
                            return c;
                        }
                        c = b.charCodeAt();
                        return '\\u00' +
                            Math.floor(c / 16).toString(16) +
                            (c % 16).toString(16);
                    });
                }
                return '"' + x + '"';
            },
            object: function (x) {
                if (x) {
                    var a = [], b, f, i, l, v;
                    if (x instanceof Array) {
                        a[0] = '[';
                        l = x.length;
                        for (i = 0; i < l; i += 1) {
                            v = x[i];
                            f = s[typeof v];
                            if (f) {
                                v = f(v);
                                if (typeof v == 'string') {
                                    if (b) {
                                        a[a.length] = ',';
                                    }
                                    a[a.length] = v;
                                    b = true;
                                }
                            }
                        }
                        a[a.length] = ']';
                    } else if (x instanceof Object) {
                        a[0] = '{';
                        for (i in x) {
                            v = x[i];
                            f = s[typeof v];
                            if (f) {
                                v = f(v);
                                if (typeof v == 'string') {
                                    if (b) {
                                        a[a.length] = ',';
                                    }
                                    a.push(s.string(i), ':', v);
                                    b = true;
                                }
                            }
                        }
                        a[a.length] = '}';
                    } else {
                        return;
                    }
                    return a.join('');
                }
                return 'null';
            }
        };
    return {
        copyright: '(c)2005 JSON.org',
        license: 'http://www.crockford.com/JSON/license.html',
        stringify: function (v) {
            var f = s[typeof v];
            if (f) {
                v = f(v);
                if (typeof v == 'string') {
                    return v;
                }
            }
            return null;
        },
        parse: function (text) {
            try {
                return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(
                        text.replace(/"(\\.|[^"\\])*"/g, ''))) &&
                    eval('(' + text + ')');
            } catch (e) {
                return false;
            }
        }
    };
}();


/*------------------------------------------------------------------------------
End Source for Jemplate - Template Toolkit for Javascript
------------------------------------------------------------------------------*/

