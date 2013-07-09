/*global $, alert */

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

var batches = [];
var jobTypes = [];
var engines = [];
var createBatchHandler = null;

var setCreateBatchHandler = function( handler ) {
   createBatchHandler = handler;
};

$(function() {
   // grab json batch info and convert into js objects/arrays
   batches = JSON.parse( $("#batch-json").text() );
   jobTypes = JSON.parse( $("#types-json").text() );
   engines = JSON.parse( $("#engines-json").text() );
      
   // create new batch popup
   $("#new-batch-popup").dialog({
      autoOpen : false,
      width : 390,
      resizable : false,
      modal : true,
      buttons : {
         "Cancel" : function() {
            $(this).dialog("close");
         },
         "Create" : function() {
            if ( createBatchHandler !== null ) {
               createBatchHandler();
            }
         }
      },
      open : function() {
         $("#new-batch-error").text("");
         $("#new-name").val("");
         $("#new-params").val("");
         $("#new-notes").val("");
         $("#new-batch-error").hide();
         $("#new-ocr").val("2");
         $("#new-type").val("2");
      }
   }); 

   $("#new-type").on("change", function() {
       var idx = parseInt($("#new-type").val(),10)-1;
       if ( idx === 2 ) {
          $("#new-batch-popup .engine-row").hide();
          $("#new-batch-popup .font-row").hide();
          $("#new-batch-popup .font-detail").hide();
       } if ( idx === 0 ) {
          $("#new-batch-popup .engine-row").show();
          $("#new-ocr").val("1");
          $("#new-batch-popup .font-row").hide();
          $("#new-batch-popup .font-detail").hide();
       } else {
          $("#new-batch-popup .engine-row").show();
          $("#new-ocr").val("2");
          $("#new-batch-popup .font-row").show();
          $("#new-batch-popup .font-detail").show();
       }
   });
   
   
   // create new FONT popup
   $("#new-font-popup").dialog({
      autoOpen : false,
      width : 350,
      resizable : false,
      modal : true,
      buttons : {
         "Cancel" : function() {
            $(this).dialog("close");
         },
         "Create" : function() {
            if ( $("#font-name").val().length === 0) {
               alert("Name is required");
               return;
            }
            if ( $("#font-file").val().length === 0) {
               alert("A training font file is required");
               return;
            }
            $('#font-upload-form').submit();
         }
      },
      open : function() {
        $("#font-name").val("");
      }
   }); 
   
   var uploadFontSuccess = function(json, statusText, xhr, form) {
      hideWaitPopup();
      $("#new-font").append($("<option></option>")
         .attr("value",json.font_id)
         .attr('selected', 'selected')
         .text(json.font_name)); 
      $("#new-font-popup").dialog("close");
   };

   var uploadFontFailed = function(jqXHR, statusText, xhr, form) {
      hideWaitPopup();
      var err = jqXHR.responseText.replace("\n", "<br/>");
      alert("Upload Source Failed", err);
   };
   
   // bind font create submit to an ajax submit with listeners
   // for pre and post submit events
   var options = {
      error : uploadFontFailed,
      success : uploadFontSuccess,
      dataType: "json" 
   };
   $('#font-upload-form').submit(function() {
      showWaitPopup("Creating font");
      $(this).ajaxSubmit(options);

      // !!! Important !!!
      // always return false to prevent standard browser submit and page navigation
      return false;
   });
   
   $("#upload-font").on("click", function() {
      $("#new-font-popup").dialog("open");
   });

});
