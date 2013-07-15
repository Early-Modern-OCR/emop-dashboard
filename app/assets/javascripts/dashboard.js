/*global $, jQuery, alert,setTimeout,clearTimeout*/
/*global setCreateBatchHandler, showWaitPopup, hideWaitPopup */

/**
 * Main javascript file for the dashboard
 */

/**
 * datatable plugin to filter on ENTER rather than every key press
 * @param {Object} oSettings
 */
jQuery.fn.dataTableExt.oApi.fnFilterOnReturn = function (oSettings) {
    var _that = this;
  
    this.each(function (i) {
        $.fn.dataTableExt.iApiIndex = i;
        var $this = this;
        var anControl = $('input', _that.fnSettings().aanFeatures.f);
        anControl.unbind('keyup').bind('keypress', function (e) {
            if (e.which == 13) {
                $.fn.dataTableExt.iApiIndex = i;
                _that.fnFilter(anControl.val());
            }
        });
        return this;
    });
    return this;
};

$(function() {
   
   hideWaitPopup();
     
   // to control tooltip mouseover behavior
   var tipShowTimer = -1;
   var tipTarget = null;
   var tipX;
   var tipY;
   
   // set status ucons based on newly scheduled job                
   var updateStatusIcons = function() {
      $(".sel-cb").each(function () {
         if ($(this).is(':checked')) {
            var status = $(this).parent().parent().find(".status-icon");
            status.removeClass().addClass("status-icon scheduled");
            $(this).prop('checked', false);
         }
      });
   };
      
   // submit a new WORKS batch
   var submitNewBatch = function() {
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
      data.works = $("#work-id-list").text();
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
      showWaitPopup("Adding works to queue");
      $.ajax({
         url : "dashboard/batch/",
         type : 'POST',
         data : data,
         success : function(resp, textStatus, jqXHR) {
            $("#pending-jobs").text(resp.pending);
            $("#running-jobs").text(resp.running);
            $("#postprocess-jobs").text(resp.postprocess);
            $("#failed-jobs").text(resp.failed);
            alert("Batch successfully added to the work queue");            
            updateStatusIcons();
            $("#new-batch-popup").dialog("close");
            hideWaitPopup();
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert(errorThrown+":"+jqXHR.responseText);
         }
      }); 
   };
   
   // schedule selected works for ocr
   var scheduleSelectedWorks = function() {
      var workIds = [];
      $(".sel-cb").each(function () {
         if ($(this).is(':checked')) {
            var id = $(this).attr("id").substring("sel-work-".length);
            workIds.push(id);
         }
      });
      if (workIds.length === 0) {
         alert("Select works to be OCR'd before clicking the 'Schedule Selected' button");
      } else {
         workIds = $.unique(workIds);
         $("#work-id-list").text(JSON.stringify(workIds) );
         setCreateBatchHandler( submitNewBatch );
         $("#new-batch-popup").dialog("open");
      }
   }; 


   // add styles to cells that are showing results
   var resultCell = function(nTd, data) {
      if ( data.length === 0 || data === -1 ) {
         $(nTd).removeClass("bad-cell");
         $(nTd).removeClass("warn-cell");
         return;
      }
      
      if ( data.indexOf("bad-cell") > -1 ) {
         $(nTd).addClass("bad-cell");
      } else if ( data.indexOf("warn-cell") > -1  ) {
         $(nTd).addClass("warn-cell");
      }
   };

   // mouse behavior to control display/hide of batch tooltip
   $("#dashboard-detail").on("mouseenter", ".batch-name", function(evt) {
      tipTarget = $(this);
      tipX = evt.pageX;
      tipY = evt.pageY;
      if (tipShowTimer === -1) {
         tipShowTimer = setTimeout(function() {
            var st = $("body").scrollTop();
            tipY-=st;
            var id = tipTarget.attr("id").substring("batch-".length);
            $.ajax({
               url : "dashboard/batch/" + id,
               type : 'GET',
               async : false,
               success : function(resp, textStatus, jqXHR) {
                  if (resp !== null) {
                     $("#dashboard-main").append(resp);
                     $("#batch-tooltip").css("top", (tipY - $("#batch-tooltip").outerHeight() / 2) + "px");
                     $("#batch-tooltip").css("left", tipX + "px");
                     $("#batch-tooltip").show();
                  }
               }
            });
         }, 750);
      }
   }); 

   $("#dashboard-detail").on("mouseleave", ".batch-name", function(evt) {
      if ( tipShowTimer !== -1 ) {
         clearTimeout( tipShowTimer );
         tipShowTimer = -1;
         tipTarget = null;
       }
       $("#batch-tooltip").remove();
   });
   $("#dashboard-detail").on("mousemove", ".batch-name", function(evt) {
      tipX = evt.pageX+10;
      tipY = evt.pageY;
   }); 
   
   // shift click to select a range of boxes
   $("#dashboard-detail").on("click", ".sel-cb", function(evt) {
      var clicked = $(this);
      if ( $(this).is(':checked') ) {
         $("#select-all").val("Deselect All");
      } else {
         var anyChecked = false;
         $(".sel-cb").each(function () {
            if ( $(this).is(':checked') ) {
               anyChecked = true;
               return false;
            }
         });
         if ( anyChecked === false ) {
            $("#select-all").val("Select All");
         }
         return true;
      }
      
      if (evt.shiftKey) {
         var foundCheck = false;
         $(".sel-cb").each(function () {
            if (foundCheck === false ) {
               if ( $(this).is(':checked') && $(this).attr("id") !== clicked.attr("id")  ) {
                  foundCheck = true;
               } 
            } else {
               if ( $(this).is(':checked') || $(this).attr("id") === clicked.attr("id")  ) {
                  return false;
               }  else {
                  $(this).prop('checked', true);
               }  
            }
         });
      }
      return true;
   }); 

   // filter stuff
   $( "#from-date" ).datepicker();
   $("#from-date").on( "change", function() {
       $("#detail-table").dataTable().fnDraw();
   });
   $( "#to-date" ).datepicker();
   $("#to-date").on( "change", function() {
       $("#detail-table").dataTable().fnDraw();
   });
   $("#batch-filter").on("change", function() {
      $("#detail-table").dataTable().fnDraw();
   }); 
   $("#set-filter").on("change", function() {
      $("#detail-table").dataTable().fnDraw();
   }); 
   $("#ocr-filter").on( "change", function() {
       $("#detail-table").dataTable().fnDraw();
   });
   $("#require-gt").on( "change", function() {
       $("#detail-table").dataTable().fnDraw();
   });
   $("#print-font-filter").on( "change", function() {
       $("#detail-table").dataTable().fnDraw();
   });
   $("#filter-reset").on("click", function() {
       $("#to-date").val("");
       $("#from-date").val("");
       $("#batch-filter").val("");
       $("#set-filter").val("");
       $("#print-font-filter").val("");
       $("#require-ocr").removeAttr('checked');
       $("#require-gt").removeAttr('checked');
       $("#detail-table").dataTable().fnDraw();
   });
 
   // Select/unselect all
   $("#select-all").on("click", function() {
      var checkIt = false;
      if ( $("#select-all").val()==="Select All") {
          $("#select-all").val("Deselect All");
          checkIt = true;
      } else {
         $("#select-all").val("Select All");
         checkIt = false;
      }
      $(".sel-cb").each(function () {
         $(this).prop('checked', checkIt);
      });
   });
   
   // Schedule
   $("#schedule-selected").on("click", function() {
      scheduleSelectedWorks();
   });
   $("#schedule-all").on("click", function() {
      $("#work-id-list").text( "all" );
      $("#new-batch-popup").dialog("open");
   });

   // create the data table instance. it has custom plug-in
   // behavior that only triggers the search filter on enter
   // instead of on each key press
   var emopTable = $('#detail-table').dataTable( {
      "iDisplayLength": 25,
      "bProcessing": true,
      "bServerSide": true,
      "bStateSave": true,
      "sAjaxSource": "dashboard/fetch",
      "sAjaxDataProp": "data",
      "bSortClasses": false,
      "aaSorting": [],
      "fnCreatedRow": function( nRow, aData, iDisplayIndex ) {
         if ( aData.ocr_engine === "Gale" ) {
             $(nRow).addClass("gale-row");            
         }
      },
      "aoColumns": [
         { "mData": "work_select" },
         { "mData": "status" },
         { "mData": "detail_link" },
         { "mData": "data_set" },         
         { "mData": "id" },
         { "mData": "tcp_number" },
         { "mData": "title" },
         { "mData": "author" },
         { "mData": "font" },
         { "mData": "ocr_date" },
         { "mData": "ocr_engine" },
         { "mData": "ocr_batch" },
         { "mData": "juxta_url" },
         { "mData": "retas_url" }
       ],
      "aoColumnDefs": [
         { "aTargets": [0], "bSortable": false},
         { "aTargets": [1], "bSortable": false},
         { "aTargets": [2], "bSortable": false},
         { "aTargets": [3], "bSortable": false},
         { "aTargets": [12], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [13], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} }
      ],
      "fnServerParams": function ( aoData ) {
         if ( $('#require-gt').is(':checked')) {
             aoData.push( { "name": "gt", "value": true } );
         }
         var ocr = $("#ocr-filter").val();
         if (ocr.length > 0) {
            aoData.push( { "name": "ocr", "value": ocr } );
         }
         var batch = $("#batch-filter").val();
         if (batch.length > 0) {
            aoData.push( { "name": "batch", "value": batch } );
         }
         var set = $("#set-filter").val();
         if (set.length > 0) {
            aoData.push( { "name": "set", "value": set } );
         }
         var pfFilter = $("#print-font-filter").val();
         if (pfFilter.length > 0) {
            aoData.push( { "name": "font", "value": pfFilter } );
         }
         var from = $("#from-date").val();
         if (from.length > 0) {
            aoData.push( { "name": "from", "value": from } );
         }
         var to = $("#to-date").val();
         if (to.length > 0) {
            aoData.push( { "name": "to", "value": to } );
         }
      }
   }).fnFilterOnReturn();   
   
   // POPUPS
   $("#ocr-work-error-popup").dialog({
      autoOpen : false,
      width : 400,
      resizable : true,
      modal : false
   }); 
   
   // Set font
   $("#font-all").on("click", function() {
      var workIds = [];
      $(".sel-cb").each(function () {
         if ($(this).is(':checked')) {
            var id = $(this).attr("id").substring("sel-work-".length);
            workIds.push(id);
         }
      });
      if (workIds.length === 0) {
         alert("Select target works before clicking the 'Set Font' button");
      } else {
         workIds = $.unique(workIds);
         $("#font-work-id-list").text(JSON.stringify(workIds) );
         $("#set-font-popup").dialog("open");
      }
   });
   
   $("#dashboard-detail").on("click", ".error", function() {
      showWaitPopup("Retrieving OCR Errors");
      var ids = $(this).attr("id").substring("status-".length).split("-");
      $.ajax({
         url : "dashboard/"+ids[0]+"/"+ids[1]+"/error",
         type : 'GET',
         success : function(resp, textStatus, jqXHR) {
            hideWaitPopup();
            $("#error-work").text(resp.work);
            $("#work-error-messages").empty();
            $.each(resp.errors, function(idx, val) {
               var p = "<div><span class='err-page'>Page "+val.page+":</span><span class='err-msg'>"+val.error+"<span></div>"
               $("#work-error-messages").append(p);
            });
            $("#ocr-work-error-popup").dialog("open");
         },
         error : function( jqXHR, textStatus, errorThrown ) {
            hideWaitPopup();
            alert("Unable to retrieve OCR errors. Cause:\n\n"+errorThrown+":"+jqXHR.responseText);
         }
      });
   });
   
   
});