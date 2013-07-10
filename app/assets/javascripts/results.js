/*global $, alert */
/*global setCreateBatchHandler, showWaitPopup, hiddeWaitPopup */


$(function() {
   // Select/unselect all
   $("#select-all-pages").on("click", function() {
      var checkIt = false;
      if ( $("#select-all-pages").val()==="Select All") {
          $("#select-all-pages").val("Deselect All");
          checkIt = true;
      } else {
         $("#select-all-pages").val("Select All");
         checkIt = false;
      }
      $(".sel-cb").each(function () {
         $(this).prop('checked', checkIt);
      });
   });
   
   // set status ucons based on newly scheduled job                
   var updatePageStatusIcons = function() {
      $(".sel-cb").each(function () {
         if ($(this).is(':checked')) {
            var status = $(this).parent().parent().find(".status-icon");
            status.removeClass().addClass("status-icon scheduled");
            $(this).prop('checked', false);
         }
      });
   };

   // submit a new WORKS batch
   var submitNewPagesBatch = function() {
      $("#new-batch-error").hide();
      var data = {};
      data.name = $("#new-name").val();
      data.type_id = $("#new-type").val();
      if (data.type_id === 3) {
         data.engine_id = 5;
      } else {
         data.engine_id = $("#new-ocr").val();
         if ($("#new-font").is(":visible")) {
            data.font_id = $("#new-font").val();
         }
      }
      data.params = $("#new-params").val();
      data.notes = $("#new-notes").val();
      data.pages = $("#work-id-list").text();
      if (data.name.length === 0) {
         $("#new-batch-error").text("* Batch name is required *");
         $("#new-batch-error").show();
         return;
      }
      if (data.type_id !== "3" && data.engine_id === "5") {
         $("#new-batch-error").text("* OCR engine is required *");
         $("#new-batch-error").show();
         return;
      }
      
      // Post the request
      showWaitPopup("Adding pages to queue");
      $.ajax({
         url : "results/batch/",
         type : 'POST',
         data : data,
         success : function(resp, textStatus, jqXHR) {
            updatePageStatusIcons();
            alert("Batch successfully added to the work queue");
            $("#new-batch-popup").dialog("close");
            hideWaitPopup();
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert(errorThrown+":"+jqXHR.responseText);
         }
      }); 
   };
   
   // schedule selected pages for ocr
   var scheduleSelectedPages = function() {
      var pageIds = [];
      $(".sel-cb").each(function () {
         if ($(this).is(':checked')) {
            var id = $(this).attr("id").substring("sel-page-".length);
            pageIds.push(id);
         }
      });
      if (pageIds.length === 0) {
         alert("Select pages to be OCR'd before clicking the 'Schedule Selected' button");
      } else {
         pageIds = $.unique(pageIds);
         $("#work-id-list").text(JSON.stringify(pageIds) );
         setCreateBatchHandler( submitNewPagesBatch );
         $("#new-batch-popup").dialog("open");
      }
   }; 
   $("#schedule-pages").on("click", function() {
      scheduleSelectedPages();
   });
   
   var work_id = $("#work-id").text();
   var batch_id = $("#batch-id").text();
   var resultTable = $('#pages-table').dataTable( {
      "bProcessing": true,
      "bServerSide": true,
      "bStateSave": false,
      "bPaginate": false,
      "bFilter": false,
      "bInfo": false,
      "bSortClasses": false,
      "sAjaxSource": "results/fetch?work="+work_id+"&batch="+batch_id,
      "sAjaxDataProp": "data",
      "aaSorting": [],
      "aoColumnDefs": [
         { "aTargets": [0], "bSortable": false},
         { "aTargets": [1], "bSortable": false},
         { "aTargets": [2], "bSortable": false},
         { "aTargets": [3], "bSortable": false},
         { "aTargets": [4], "bSortable": false}
      ],
      "aoColumns": [
         { "mData": "page_select" },
         { "mData": "status" },
         { "mData": "page_image" },
         { "mData": "ocr_text" },
         { "mData": "detail_link" },
         { "mData": "page_number" },
         { "mData": "juxta_accuracy" },
         { "mData": "retas_accuracy" }
       ]
   }).fnFilterOnReturn();
   
   // create new FONT popup
   $("#ocr-view-popup").dialog({
      autoOpen : false,
      width : 350,
      height: 450,
      resizable : true,
      modal : false
   }); 
   
   $("#results-detail").on("click", ".ocr-txt", function() {
      showWaitPopup("Retrieving OCR Results");
      var id = $(this).attr("id").substring("result-".length);
      $.ajax({
         url : "results/"+id+"/text",
         type : 'GET',
         success : function(resp, textStatus, jqXHR) {
            hideWaitPopup();
            $("#ocr-page-num").text(resp.page);
            $("#ocr-text-display").val(resp.content);
            $("#ocr-view-popup").dialog("open");
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert("Unable to retrieve OCR results. Cause:\n\n"+errorThrown+":"+jqXHR.responseText);
         }
      });
   });
   
   $("#results-detail").on("click", ".detail-link", function() {
      showWaitPopup("Visualizing");
   });
});