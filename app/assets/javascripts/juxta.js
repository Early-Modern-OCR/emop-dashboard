// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {
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

   var initialize = function() {  
      hideWaitPopup();
   };

   showWaitPopup(true, "Visualizing");
   $("body").on("sidebyside-loaded", function() {
      initialize();
   });
});

