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

   // Select/unselect failed
   $('#select-failed-pages').on('click', function(event) {
      var inputs = $('td div.error').closest('tr').find('input.sel-cb');
      var select = false;
      if ($(this).val() == 'Select Failed') {
         $(this).val('Deselect Failed');
         select = true;
      } else {
         $(this).val('Select Failed');
         select = false;
      }
      $(inputs).each(function() {
         this.checked = select;
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

   // submit a new PAGES batch
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
      data.json = $("#batch-json").text();
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
            showWaitPopup("Loading new batch");
            window.location.replace("/results?work="+$("#work-id").text()+"&batch="+resp);
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert(errorThrown+":"+jqXHR.responseText);
         }
      }); 
   };
   
   // reschedule failed pages
   var reschedulePages = function(data) {
      $.ajax({
         url : "results/reschedule",
         type : 'POST',
         data : data,
         success : function(resp, textStatus, jqXHR) {
            showWaitPopup("Refreshing results...");
            $("#ocr-error-popup").dialog("close");
            window.location.reload();
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert("Unable to reschedule page. Cause:\n\n"+errorThrown+":"+jqXHR.responseText);
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
         var err = 0;
         var sched = 0;
         $.each(pageIds, function(idx, val) {
            var si = $("#sel-page-"+val).parent().parent().find(".status-icon");
            if ( si.hasClass("scheduled") ) {
               sched = sched+1;
            }
            if ( si.hasClass("error") ) {
               err=err+1;
            }
         });
         if ( sched > 0 ) {
            alert("Some of these pages are already scheduled. Cannot schedule them again until processing is complete.\n\nPlease select other pages and try again.");
         } else if (err > 0 ) {
            if ( err <  pageIds.length ) {
               alert("Cannot schedule a mix of pages with and without errors.\n\nPleae select other pages and try again.");
            } else {
               data = { type: 'page', work: $("#work-id").text(), batch: $("#batch-id").text(), pages:  pageIds};
               $("#resubmit-data").text( JSON.stringify(data) );
               
               setCreateBatchHandler( submitNewPagesBatch );
               setRescheduleHandler( function() {
                  showWaitPopup("Rescheduling Pages...");
                  reschedulePages($.parseJSON($("#resubmit-data").text()));
                  $("#confirm-resubmit-popup").dialog("close");
               });
               $("#confirm-resubmit-popup").dialog("open");
            }
         } else {
            $("#batch-json").text(JSON.stringify({work:$("#work-id").text(), pages: pageIds}) );
            setCreateBatchHandler( submitNewPagesBatch );
            $("#new-batch-popup").dialog("open");
         }
      }
   }; 
   $("#schedule-pages").on("click", function() {
      scheduleSelectedPages();
   });
   
   var work_id = $("#work-id").text();
   var batch_id = $("#batch-id").text();

  jQuery.fn.dataTableExt.oSort['results-asc'] = function(x,y) {
    var retVal;
    x = $.trim(x);
    y = $.trim(y);

    if (x==y) retVal= 0;
    else if (x == "" || x == "-") retVal =  1;
    else if (y == "" || y == "-") retVal =  -1;
    else if (parseFloat(x) > parseFloat(y)) retVal =  1;
    else retVal = -1;

    return retVal;
  }
  jQuery.fn.dataTableExt.oSort['results-desc'] = function(y,x) {
    var retVal;
    x = $.trim(x);
    y = $.trim(y);
    if (x==y) retVal= 0;
    else if (x == "" || x == "-") retVal =  -1;
    else if (y == "" || y == "-") retVal =  1;
    else if (parseFloat(x) > parseFloat(y)) retVal =  1;
    else retVal = -1;

    return retVal;
  }

  jQuery.fn.dataTableExt.oSort['data-id-asc'] = function(x,y) {
    var retVal;
    x = $(x).data('id');
    y = $(y).data('id');

    if (x==y) retVal= 0;
    else if (parseInt(x) > parseInt(y)) retVal =  1;
    else retVal = -1;

    return retVal;
  }
  jQuery.fn.dataTableExt.oSort['data-id-desc'] = function(y,x) {
    var retVal;
    x = $(x).data('id');
    y = $(y).data('id');

    if (x==y) retVal= 0;
    else if (parseInt(x) > parseInt(y)) retVal =  1;
    else retVal = -1;

    return retVal;
   }

   $('#pages-table').dataTable({
     "bAutoWidth": false,
     "bProcessing": true,
     "bPaginate": false,
     "bFilter": false,
     "bInfo": false,
     "bSortClasses": false,
     "aaSorting": [[6, "asc"]],
     "aoColumnDefs": [
       { "aTargets": [0], "bSortable": false }, //select
       { "aTargets": [1], "sType": "data-id" }, //status
       { "aTargets": [2], "bSortable": false }, //image
       { "aTargets": [3], "bSortable": false }, //ocr text
       { "aTargets": [4], "bSortable": false }, //ocr hocr
       { "aTargets": [5], "bSortable": false }, //juxta diff
       { "aTargets": [6] }, //page #
       { "aTargets": [7], "sType": "results" }, //juxta score
       { "aTargets": [8], "sType": "results" }, //retas score
       { "aTargets": [9], "sType": "results" }, //ecorr
       { "aTargets": [10], "sType": "results" }, //pg quality
       { "aTargets": [11], "sType": "results" }, //stat-1
       { "aTargets": [12], "sType": "results" }, //stat-2
       { "aTargets": [13], "sType": "results" }, //stat-3
       { "aTargets": [14], "sType": "results" }, //stat-4
       { "aTargets": [15], "sType": "results" }, //stat-5
     ],
     "fnInitComplete": function() {
       $("#pages-table").show();
     },
   });

   $(".page-view").on("click", function() {
     showWaitPopup("Getting page image");
     setTimeout(hideWaitPopup, 1000);
   });

   // Set work print font
   $("#set-work-font").on("click", function() {
      workIds = [ $("#work-id").text() ];
      $("#font-work-id-list").text(JSON.stringify(workIds) );
      $("#set-font-popup").dialog("open");
   });
   
   // Download text or hOCR results for a page
   // FIXME
   var downloadItem = function(url) {
      showWaitPopup("Downloading results...");
      var token = new Date().getTime();
      window.location = url + "?token=" + token;
      var limit = 10;
      var intId = setInterval(function() {
         var cookieValue = $.cookie('fileDownloadToken');
         limit -= 1;
         if (cookieValue == token || limit <= 0) {
            hideWaitPopup();
            clearInterval(intId);
         }
      }, 500);
   }; 

   $('#ocr-view-info').tabs({
     active: 2, //Set corrected tab as active by default
     heightStyle: "auto"
   });
   // POPUPS
   $("#ocr-view-popup").dialog({
      autoOpen : false,
      width : 500,
      height: 500,
      resizable : true,
      modal : false,
      buttons : {
         "Close" : function() {
            $(this).dialog("close");
         },
         "Download" : function() {
           var active_tab = $("#ocr-view-info").tabs("option", "active");
           var url = $(".file-info").eq(active_tab).data("url");
            $(this).dialog("close");
            downloadItem(url);
          }
      }
   }); 
   $("#ocr-error-popup").dialog({
      autoOpen : false,
      width : 350,
      resizable : true,
      modal : false
   }); 
   
   // get OCR results as TEXT
   $("#results-detail").on("click", ".ocr-txt", function() {
      // Exit function if the element is disabled
      if ($(this).hasClass("disabled")) {
         return;
      }
      showWaitPopup("Retrieving OCR results...");
      var id = $(this).data('id');
      $.ajax({
         url : $(this).data('source'),
         type : 'GET',
         success : function(resp, textStatus, jqXHR) {
            hideWaitPopup();
            $("#tgt-result-id").text(id);
            $("#result-type").text("Text");
            $("#ocr-page-num").text(resp.page);
            // Original values
            $("#ocr-original-path").text(resp.original_path);
            $(".file-info:eq(0)").attr("data-url", resp.original_url);
            $("#ocr-original-display").val(resp.original_content);
            // Processed values
            $("#ocr-processed-path").text(resp.processed_path);
            $(".file-info:eq(1)").attr("data-url", resp.processed_url);
            $("#ocr-processed-display").val(resp.processed_content);
            // Corrected values
            $("#ocr-corrected-path").text(resp.corrected_path);
            $(".file-info:eq(2)").attr("data-url", resp.corrected_url);
            $("#ocr-corrected-display").val(resp.corrected_content);
            $("#ocr-view-popup").dialog("open");
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert("Unable to retrieve text results. Cause:\n\n"+errorThrown+":"+jqXHR.responseText);
         }
      });
   });
   
    // get OCR results as hOCR
   $("#results-detail").on("click", ".ocr-hocr", function() {
      // Exit function if the element is disabled
      if ($(this).hasClass("disabled")) {
         return;
      }
      showWaitPopup("Retrieving hOCR results...");
      var id = $(this).data('id');
      $.ajax({
         url : $(this).data('source'),
         type : 'GET',
         success : function(resp, textStatus, jqXHR) {
            hideWaitPopup();
            $("#tgt-result-id").text(id);
            $("#result-type").text("hOCR");
            $("#ocr-page-num").text(resp.page);
            // Original values
            $("#ocr-original-path").text(resp.original_path);
            $(".file-info:eq(0)").attr("data-url", resp.original_url);
            $("#ocr-original-display").val(resp.original_content);
            // Processed values
            $("#ocr-processed-path").text(resp.processed_path);
            $(".file-info:eq(1)").attr("data-url", resp.processed_url);
            $("#ocr-processed-display").val(resp.processed_content);
            // Corrected values
            $("#ocr-corrected-path").text(resp.corrected_path);
            $(".file-info:eq(2)").attr("data-url", resp.corrected_url);
            $("#ocr-corrected-display").val(resp.corrected_content);
            $("#ocr-view-popup").dialog("open");
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert("Unable to retrieve hOCR results. Cause:\n\n"+errorThrown+":"+jqXHR.responseText);
         }
      });
   });

   $("#results-detail").on("click", ".error", function() {
      showWaitPopup("Retrieving OCR Error");
      var ids = $(this).attr("id").substring("status-".length).split("-");
      $("#err-batch-id").text(ids[0]);
      $("#err-page-id").text(ids[1]);
      $.ajax({
         url : "results/"+ids[0]+"/"+ids[1]+"/error",
         type : 'GET',
         success : function(resp, textStatus, jqXHR) {
            hideWaitPopup();
            $("#error-page").text(resp.page);
            $("#page-error-message").text(resp.error);
            $("#ocr-error-popup").dialog("open");
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert("Unable to retrieve OCR errors. Cause:\n\n"+errorThrown+":"+jqXHR.responseText);
         }
      });
   });
   
   $("#reschedule-page").on("click", function() {
      showWaitPopup("Rescheduling Page...");
      data = { batch: $("#err-batch-id").text(), pages:  [$("#err-page-id").text()]}
      reschedulePages(data);
   });
   
   $("#results-detail").on("click", ".juxta-link", function() {
      // Exit function if the element is disabled
      if ($(this).hasClass("disabled")) {
         return;
      }
      showWaitPopup("Visualizing");
   });
});