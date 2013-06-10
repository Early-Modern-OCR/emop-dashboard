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
   
   var initScrollHeight = function() {
      $("#page-scroller").css("overflow-x", "hidden");
      $("#page-scroller").css("overflow-y", "hidden");
      var windowH = $(window).height();
   
      var mainTitleH = $(".main-header").outerHeight();
      var newH = windowH - mainTitleH - 30;
      $("#page-scroller").height(newH);
   };

   var initialize = function() {  
      initScrollHeight();
      hideWaitPopup();
   };

   showWaitPopup("Visualizing");
   $("body").on("sidebyside-loaded", function() {
      initialize();
   });
});

