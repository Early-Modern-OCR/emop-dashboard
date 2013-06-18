
var showWaitPopup = function( message ) {
   $('#dim-overlay').show();
   $("#wait-spinner").show();
   $("#wait-msg").text(message);
   $("#wait-msg").show();
   $('#wait-popup').show();
};

var hideWaitPopup = function() {
   $('#dim-overlay').hide();
   $("#wait-popup").hide();
};


$.fn.hasScrollBar = function() {
   return this.get(0).scrollHeight > this.height();
};
$.fn.exists = function() {
   return this.length !== 0;
};
