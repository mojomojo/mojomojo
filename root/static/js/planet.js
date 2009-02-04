var toggle = new Object;
toggle = {
	swap: function() {
		var d=document,t=this;
		if (!d.getElementById('toc-control') || !d.getElementById('toc-body')) return;
		var toc_ctl  = d.getElementById('toc-control');
		var toc_body = d.getElementById('toc-body');
		if (toc_body.style.display=='none') {
			toc_body.style.display='';
			toc_ctl.innerHTML = '<img src=\"/+static/themes/catalyst/images/tog-up.gif\" style=\"border:0\" onclick="toggle.swap();return false;" alt="Hide TOC" />';
		} else {
			toc_body.style.display='none';
			toc_ctl.innerHTML = '<img src=\"/+static/themes/catalyst/images/tog-down.gif\" style=\"border:0\" onclick="toggle.swap();return false;" alt="Show TOC" />';
		}
	}
}

/* The following JavaScript code is adapted from the Typo blog engine:
http://www.typosphere.org/trac/browser/trunk/public/javascripts/typo.js

Copyright (c) 2005 Tobias Luetke

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

function show_dates_as_local_time() {
	var spans = document.getElementsByTagName('span');
	for (var i=0; i<spans.length; i++) {
		if (spans[i].className.match(/\bentry-post-date\b/i)) {
			spans[i].innerHTML = get_local_time_for_date(spans[i].title);
		}
	}
}

function get_local_time_for_date(time) {
	system_date = new Date(time);
	user_date = new Date();
	delta_minutes = Math.floor((user_date - system_date) / (60 * 1000));
	if (Math.abs(delta_minutes) <= (8*7*24*60)) { // eight weeks... I'm lazy to count days for longer than that
		distance = distance_of_time_in_words(delta_minutes);
		if (delta_minutes < 0) {
			return distance + ' from now';
		} else {
			return distance + ' ago';
		}
	} else {
		return 'on ' + system_date.toLocaleDateString();
	}
}

function distance_of_time_in_words(minutes) {
	if (minutes.isNaN) return "";
	minutes = Math.abs(minutes);
	if (minutes < 1) return ('less than a minute');
	if (minutes < 50) return (minutes + ' minute' + (minutes == 1 ? '' : 's'));
	if (minutes < 90) return ('about one hour');
	if (minutes < 1080) return (Math.round(minutes / 60) + ' hours');
	if (minutes < 1440) return ('one day');
	if (minutes < 2880) return ('about one day');
	else return (Math.round(minutes / 1440) + ' days')
}
