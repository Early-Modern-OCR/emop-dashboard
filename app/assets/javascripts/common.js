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
var fonts = [];
var createBatchHandler = null;

var setCreateBatchHandler = function( handler ) {
   createBatchHandler = handler;
};

$(function() {
   // grab json batch info and convert into js objects/arrays
   batches = JSON.parse( $("#batch-json").text() );
   jobTypes = JSON.parse( $("#types-json").text() );
   engines = JSON.parse( $("#engines-json").text() );
   fonts = JSON.parse( $("#fonts-json").text() );
   
   var showFontDetail = function() {
      if ( fonts.length === 0 ) {
         $("#new-font").hide();
         $("#no-fonts").show();
         $("#new-batch-popup .font-row").show();
         $("#new-batch-popup .font-detail").hide();
      } else {
         var idx = parseInt($("#new-font").val(), 10) - 1;
         var font = fonts[idx];
         $("#new-fonts").show();
         $("#new-batch-popup .batch-font").text(font.font_name);
         $("#new-batch-popup .font-italic").text(font.font_italic);
         $("#new-batch-popup .font-bold").text(font.font_bold);
         $("#new-batch-popup .font-fixed").text(font.font_fixed);
         $("#new-batch-popup .font-serif").text(font.font_serif);
         $("#new-batch-popup .font-fraktur").text(font.font_fraktur);
         $("#new-batch-popup .font-height").text(font.font_line_height);
         $("#new-batch-popup .font-path").text(font.font_library_path);
         $("#new-batch-popup .font-row").show();
         $("#new-batch-popup .font-detail").show();
      }
   };
    
   // create new batch popup
   $("#new-batch-popup").dialog({
      autoOpen : false,
      width : 420,
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
         showFontDetail();
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
       } else {
          $("#new-batch-popup .engine-row").show();
          $("#new-batch-popup .font-row").show();
          $("#new-batch-popup .font-detail").show();
       }
   });
   $("#new-font").on("change", function() {
      showFontDetail();
   }); 

});
