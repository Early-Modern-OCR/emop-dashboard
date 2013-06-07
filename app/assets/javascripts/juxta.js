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
      var data =  {work: $("#work-id").text(),  batch: $("#batch-id").text(),  collation: id };
      
      // handle each case
      if (status === 'error') {
         // reset back to uninitalized and tack on a clear flag.
         // this tells the server to clear out old data and repopulate
         // the collation with new information
         status = 'uninitialized';
         data.clear = true;
      }
      
      // Uninitialized collations must upload sources, use them to create witnesses and a set
      // then collaate the results. after that the status moves to ready.
      if (status === 'uninitialized') {
         $.ajax({
            url : "/juxta",
            data : data,
            type : 'POST',
            success : function(resp, textStatus, jqXHR) {
               if (resp !== null) {
                  alert("yay");
                  hideWaitPopup();
               }
            },
            error : function(jqXHR, textStatus, errorThrown) {
               alert(textStatus);
               hideWaitPopup();
            }
         });
      } else {
         // TODO
      }
   };

   showWaitPopup(true, "Visualizing");
   $("body").on("sidebyside-loaded", function() {
      initialize();
   });
});

