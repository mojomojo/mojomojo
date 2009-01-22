//##############################
// jQuery FCKEditor Plugin
// By Diego A. - diego@fyneworks.com
// 10-Aug-2007 - Added setHTML method
// 12-Jan-2008 - v1.1 - plugin now follows the jquery philosophy of $(selector).plugin();
// 12-Jan-2008 - v1.1 - the new structure allows multiple FCk configurations on one page
/*
 USAGE:
		$('textarea').fck({ path:'/path/to/fck/editor/' }); // initialize FCK editor

	ADVANCED USAGE:
		$.fck.update(); // update value in textareas of each FCK editor instance
*/

/*# AVOID COLLISIONS #*/
if(jQuery) (function($){
/*# AVOID COLLISIONS #*/

$.extend($, {
	fck:{
		config: { Config: {} }, // default configuration
		path: '/.static/js/fckeditor/', // default path to FCKEditor directory
  list: [], // holds a list of instances
  loaded: false, // flag indicating whether FCK script is loaded
		intercepted: null, // variable to store intercepted method(s)

		// utility method to read contents of FCK editor
		content: function(i, v){
			try{
				var x = FCKeditorAPI.GetInstance(i);
				if(v) x.SetHTML(v);
				return x.GetXHTML(true);
			}catch(e){ return ''; };
		}, // fck.content function

		// inspired by Sebastián Barrozo <sbarrozo@b-soft.com.ar>
		setHTML: function(i, v){
			if(typeof i=='object'){
				v = i.html;
				i = i.InstanceName || i.instance;
			};
			return $.fck.content(i, v);
		},

		// utility method to update textarea contents before ajax submission
		update: function(){
			// Update contents of all instances
			var e = $.fck.list;
			for(var i=0;i<e.length;i++){
				var ta = e[i].textarea;
				var ht = $.fck.content(e[i].InstanceName);
				ta.val(ht).filter('textarea').text(ht);
				if(ht!=ta.val())
				 alert('Critical error in FCK plugin:'+'\n'+'Unable to update form data');
			}
		}, // fck.update

		// utility method to create instances of FCK editor (if any)
		create: function(o/* options */){
			o = $.extend($.fck.config || {}, o || {});
			// Plugin options
			$.extend(o,{
				selector: (o.selector || 'textarea.fck'),
			 BasePath: (o.path || o.BasePath || $.fck.path)
			});
			// Find fck.editor-instance 'wannabes'
			var e = $(o.e);
			if(!e.length>0) e = $(o.selector);
			if(!e.length>0) return;
			// Load script and create instances
			if($.fck.loaded){
				$.fck.editor(e,o);
			}
			else{
				$.getScript(
					o.BasePath+'fckeditor.js',
					function(){
						$.fck.loaded = true;
						$.fck.editor(e,o);
					}
				);
			};
			// Return matched elements...
			return e;
		},

		// utility method to integrate this plugin with others...
		intercept: function(){
			if($.fck.intercepted) return;
			// This method intercepts other known methods which
			// require up-to-date code from FCKEditor
			$.fck.intercepted = {
			 ajaxSubmit: $.fn.ajaxSubmit || function(){}
			};
			$.fn.ajaxSubmit = function(){
				//LOG('#########################################');
				//LOG($.fck.list);
				//LOG('#########################################');
				$.fck.update(); // update html
				return $.fck.intercepted.ajaxSubmit.apply( this, arguments );
			};
		},

		// utility method to create an instance of FCK editor
		editor: function(e /* elements */, o /* options */){
			o = $.extend($.fck.config || {}, o || {});
			// Default configuration
			$.extend(o,{
			 Width: (o.width || o.Width || '100%'),
			 Height: (o.height || o.Height|| '500px'),
			 BasePath: (o.path || o.BasePath || $.fck.path),
			 ToolbarSet: (o.toolbar || o.ToolbarSet || 'Default'),
			 Config: (o.config || o.Config || {})
			});
			/*
			// not in use by this plugin
			$.extend(o.Config,{
    CustomConfigurationsPath: o.BasePath+'fck.js'
   });
			*/
			// Make sure we have a jQuery object
			e = $(e);
			if(e.size()>0){
				// Local array to store instances
				var a = ($.fck.list || []);
				// Go through objects and initialize fck.editor
				e.each(
					function(i,t){
						var T = $(t);// t = element, T = jQuery
						t.name = (t.name || 'fck'+($.fck.list.length+1));
						t.id = (t.id || t.name);
						if(t.id/* has id */ && !t.fck/* not already installed */){
							var n = a.length;

							a[n] = new FCKeditor(t.id);
							$.extend(a[n], o);
							a[n].ReplaceTextarea();
							a[n].textarea = T;

							t.fck = a[n];
						};
					}
				);
				// Store instances in global array
				$.fck.list = a;
			};
			// return jQuery array of elements
		 return e;
		}, // fck.editor function

		// start-up method
		start: function(o/* options */){
			// Attach itself to known plugins...
			$.fck.intercept();
			// Create FCK editors
			return $.fck.create(o);
		} // fck.start

 } // fck object
	//##############################

});
// extend $
//##############################


$.extend($.fn, {
 fck: function(o){
		$.fck.start($.extend(o || {}, {e: this}));
	}
});
// extend $.fn
//##############################

/*# AVOID COLLISIONS #*/
})(jQuery);
/*# AVOID COLLISIONS #*/
