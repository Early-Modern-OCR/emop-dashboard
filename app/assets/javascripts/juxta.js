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
   
   var changeWaitMessage = function(msg) {
      $("#wait-msg").text(msg);
      $("#wait-msg").show();
   }

   var hideWaitPopup = function() {
      $('#dim-overlay').hide();
      $("#wait-popup").hide();
   };

   var initialize = function() {  
      // Get the status of this collation
      var status = $("#collation-status").text();
      var id = $("#collation-id").text();
      
      // handle each case
      if ( status === 'uninitialized' ) {
         $.ajax({
               url : "/juxta",
               data : { work: $("#work-id").text(),  batch: $("#batch-id").text(),  collation: id },
               type : 'POST',
               success : function(resp, textStatus, jqXHR) {
                  if (resp !== null) {
                     alert("yay");
                  }
               },
               error : function( jqXHR, textStatus, errorThrown ) {
                  alert(errorThrown);
               }
            });
      } 
      
      hideWaitPopup();
   };

   showWaitPopup(true, "Visualizing");
   $("body").on("sidebyside-loaded", function() {
      initialize();
   });
});

