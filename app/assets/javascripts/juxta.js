// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

$(function() {   

   $.fn.hasScrollBar = function() {
      return this.get(0).scrollHeight > this.height();
   };
   $.fn.exists = function() {
      return this.length !== 0;
   };
   
   var initScrollHeight = function() {
      $("#page-scroller").css("overflow-x", "hidden");
      $("#page-scroller").css("overflow-y", "hidden");
      var windowH = $(window).height();
   
      var mainTitleH = $(".main-header").outerHeight();
      var summaryH = $("#results-summary").outerHeight();
      var backH = $("#back-bar").outerHeight();
      var newH = windowH - mainTitleH - summaryH - backH - 60;
      $("#page-scroller").height(newH);
   };
   
   var initialize = function() {
      initScrollHeight();
      Juxta.SideBySide.initialize();
      setTimeout(function() {
         if ( $("#right-witness-text").exists() && $("#right-witness-text").hasScrollBar()) {
            $("#scroll-mode").show();
         }
      }, 1000);
      hideWaitPopup();
   }; 

   // basic page setup. Hide some stuff from juxta
   // that is not relevant here. wait for sbs to be initialized,
   // then call local initialiation. NOTE: do the hiding stuff
   // before the wait-for-init so the user never gets a chance to see it.
   showWaitPopup("Visualizing");
   $("#left-witness .sbs-title").text("Ground Truth");
   $("#right-witness .sbs-title").text("OCR Result");
   $("#change-left").hide();
   $("#change-right").hide();
   $("#scroll-mode").hide();
   $("body").on("sidebyside-loaded", function() {
      initialize();
   });
   
   $(window).resize(function() {
      initScrollHeight();
   });
});

