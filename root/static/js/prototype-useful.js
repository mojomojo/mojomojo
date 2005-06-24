/* prototype-useful.js - Some useful additions for the prototype library */
/* By Marcus Ramberg */

document.registerAction = function(element,action,functionName) {
    element=$(element);
    if (element) {
        try { 
            element.addEventListener(action, functionName, false);
        } catch(e) { }
        try { 
            element.attachEvent('on'+action, functionName, false);
        } catch(e) { 
          element['on'+action]=functionName;
        }
    }
}


Form.Element.SmartObserver = Class.create();
Form.Element.SmartObserver.prototype = {
    initialize: function(element,delay,callback) {
        this.delay = delay;
        this.element = $(element);
        this.callback = callback;
        this.lastValue = this.getValue();

        document.registerAction(this.element, 'keyup', this.registerCallback.bind(this));
    },
    registerCallback: function() {
        if (this.timer) clearTimeout(this.timer);
        this.timer = setTimeout(this.onTimerEvent.bind(this), this.delay*1000);
    },
   onTimerEvent: function() {
      var value = this.getValue();
      if (this.lastValue != value) {
          this.callback(this.element, value);
          this.lastValue = value;
      }
    },
  getValue: function() {
      return Form.Element.getValue(this.element);
  }
}

Element.HoverObserver = Class.create();
Element.HoverObserver.prototype = {
    initialize: function(element,delay,callback) {
        this.delay = delay;
        this.element = $(element);
        this.callback = callback;

        document.registerAction(this.element, 'mouseover', this.registerCallback.bind(this));
        document.registerAction(this.element, 'mouseout', this.cancelCallback.bind(this));
    },
    registerCallback: function() {
        if (this.timer) clearTimeout(this.timer);
        this.timer = setTimeout(this.onTimerEvent.bind(this), this.delay*1000);
    },
    cancelCallback: function() {
        if (this.timer) clearTimeout(this.timer);
    },
   onTimerEvent: function() {
      this.callback(this.element);
    }
}
