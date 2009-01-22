/*
 * Copyright (c) 2008-2009 Olle Törnström studiomediatech.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * Very simple image time based image slideshow.
 *
 * Simple to use on an image element, for example:
 *
 * <img src="myStartImage.jpg" alt="" id="slideMe" />
 *
 * $('#slideMe').Slides({images : ['image1.jpg', 'image2.jpg']});
 * 
 * Will rotate over the images in the passed images array.
 *
 * $('#slideMe').Slides({images : [...], pause : 6000, fade : 3000});
 *
 * Will set the pause time on each slide to 6s and the fade
 * transition time to 3s.
 *
 * Default values are 6s and 1s.
 * 
 * @author Olle Törnström olle[at]studiomediatech[dot]com
 * @since 2009-01-15
 * @version 1.0.0-ALPHA
 */
;(function($) {

	var settings = {};

	$.fn.Slides = function(options) {
		var finals = {};
		$.fn.Slides.setup(finals, $.fn.Slides.defaults, options);
		var that = this;
		$.fn.Slides.init(this, function() {
			return that.each(function() {
				$(that).Slides.execute();
			});
		});
	};

	$.fn.Slides.defaults = {
		pause : 6000,
		fade : 1000
	};	

	$.fn.Slides.setup = function(finals, defaults, options) {
		settings = $.extend({}, finals || {}, defaults || {}, options || {});
	};		
	
	$.fn.Slides.init = function(target, callback) {		
		if (typeof settings.images === 'undefined')
			throw Error('Image array is not optional must be passed in the call $("#id").Slides({images : ["img1.jpg", "img2.jpg"]})');
		settings.main = $(target);
		var isInit = false;
		var initWrapper = function() {
			isInit = true;
			settings.toggle = settings.main.wrap('<span></span>')
					.parent()
					.css({display : 'inline-block', overflow : 'hidden', height : settings.main.height() + 'px', width : settings.main.width() + 'px'});
			$.fn.Slides.preloadNextImage();
		};
		settings.main.load(function() {
			if (isInit)
				return;
			initWrapper();
			callback.call();
		});		
		if (settings.main[0].complete && !isInit) {
			initWrapper();
			callback.call();
		}
	};

	$.fn.Slides.preloadNextImage = function() {
		var nextImage = $.fn.Slides.getNextImage();
		var image = new Image();
		image.src = nextImage;
		settings.nextImage = image;
	};

	$.fn.Slides.getNextImage = function() {
		var nextImage = settings.images.shift();
		settings.images.push(nextImage);
		return nextImage;	
	};
	
	$.fn.Slides.execute = function() {
		var isToggle = false;
		setInterval(function() {
			if (isToggle) {
				settings.main.attr('src', settings.nextImage.src).animate({opacity : 1}, settings.fade);
				isToggle = false;
			} else {
				settings.toggle.css({background : 'transparent url(' + settings.nextImage.src + ') left top no-repeat'});
				settings.main.animate({opacity : 0}, settings.fade);				
				isToggle = true;
			}
			$.fn.Slides.preloadNextImage();
		}, settings.pause);
	};

})(jQuery);
