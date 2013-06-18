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
   
   // grab json batch info and convert into js objects/arrays
   var batches = [];
   if (  $("#batch-json").exists() ) {
      batches = JSON.parse( $("#batch-json").text() );
   }
   var jobTypes = [];
   if (  $("#types-json").exists() ) {
      job_types = JSON.parse( $("#types-json").text() );
   }
   var engines = [];
   if (  $("#engines-json").exists() ) {
      engines = JSON.parse( $("#engines-json").text() );
   }
   var fonts = [];
   if (  $("#fonts-json").exists() ) {
      fonts = JSON.parse( $("#fonts-json").text() );
   }
   
   // to control tooltip mouseover behavir
   var tipShowTimer = -1;
   var tipTarget = null;
   var tipX;
   var tipY;
   
   // Initialize jQuery UI popups
   var initPopups = function() {
        
      // Pick batch popiup
      $("#pick-batch-popup").dialog({
         autoOpen : false,
         width : 350,
         resizable : false,
         modal : true,
         buttons : {
            "Cancel" : function() {
               $(this).dialog("close");
            },
            "New Batch" : function() {
               $("#new-batch-popup").dialog("open");
            },
            "Schedule Jobs" : function() {
               // TODO
            }
         }
      }); 
      
      $("#batch-pick").on("change", function() {
         var idx = parseInt($("#batch-pick").val(),10)-1;
         if ( idx >= 0 ) {
            var batch = batches[idx];
            $("#batch-type").text(batch.type.name);
            if ( batch.type.id !== 3 ) {
               $("#batch-engine").text(batch.engine.name);
               $(".engine-row").show();
               if ( batch.font != null ) {
                  $("#pick-batch-popup .batch-font").text(batch.font.font_name);
                  $("#pick-batch-popup .font-italic").text(batch.font.font_italic);
                  $("#pick-batch-popup .font-bold").text(batch.font.font_bold);
                  $("#pick-batch-popup .font-fixed").text(batch.font.font_fixed);
                  $("#pick-batch-popup .font-serif").text(batch.font.font_serif);
                  $("#pick-batch-popup .font-fraktur").text(batch.font.font_fraktir);
                  $("#pick-batch-popup .font-height").text(batch.font.font_line_height);
                  $("#pick-batch-popup .font-path").text(batch.font.font_library_path);
                  $(".font-row").show();
                  $(".font-detail").show();
               } else {
                  $("#batch-font").text("");
                  $(".font-row").hide();
                  $(".font-detail").hide();
               }
            } else {
               $("#batch-engine").text("");
               $("#batch-font").text("");
               $(".engine-row").hide();
               $(".font-row").hide();
               $(".font-detail").hide();
            }
            $("#batch-params").text(batch.parameters);
            $("#batch-notes").text(batch.notes);
         } else {
            $("#batch-type").text("");
            $("#batch-engine").text("");
            $("#batch-font").text("");
            $(".engine-row").hide();
            $(".font-row").hide();
            $("#batch-params").text("");
            $("#batch-notes").text("");
         }
      }); 
      
      // NEW batch
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
            $("#new-batch-popup .font-fraktur").text(font.font_fraktir);
            $("#new-batch-popup .font-height").text(font.font_line_height);
            $("#new-batch-popup .font-path").text(font.font_library_path);
            $("#new-batch-popup .font-row").show();
            $("#new-batch-popup .font-detail").show();
         }
      };
      
      // create new batch popup 
      $("#new-batch-popup").dialog({
         autoOpen : false,
         width : 400,
         resizable : false,
         modal : true,
         buttons : {
            "Cancel" : function() {
               $(this).dialog("close");
            },
            "Create" : function() {
               // TODO
            }
         },
         open : function() {
            showFontDetail();
         }
      });
      
      $("#new-type").on("change", function() {
          var idx = parseInt($("#new-type").val(),10)-1;
          if ( idx === 2 ) {
             $("#new-batch-popup .engine-row").hide();
             $("#new-batch-popup .font-row").hide();
          } else {
             $("#new-batch-popup .engine-row").show();
             $("#new-batch-popup .font-row").show();
          }
      });
      $("#new-font").on("change", function() {
         showFontDetail();
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
         $("#pick-batch-popup").dialog("open");
      }
   }; 


   // add styles to cells that are showing results
   var resultCell = function(nTd, data) {
      if ( data.length === 0 || data == -1 ) {
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
   
   // initialize all popups!
   initPopups();

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
   $("#require-ocr").on( "change", function() {
       $("#detail-table").dataTable().fnDraw();
   });
   $("#filter-reset").on("click", function() {
       $("#to-date").val("");
       $("#from-date").val("");
       $("#batch-filter").val("");
       $("#require-ocr").removeAttr('checked');
       $("#detail-table").dataTable().fnDraw();
   });
   
   // Schedule
   $("#schedule-selected").on("click", function() {
      scheduleSelectedWorks();
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
         { "mData": "detail_link" },
         { "mData": "status" },
         { "mData": "data_set" },
         { "mData": "tcp_number" },
         { "mData": "title" },
         { "mData": "author" },
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
         { "aTargets": [10], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [11], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} }
      ],
      "fnServerParams": function ( aoData ) {
         if ( $('#require-ocr').is(':checked')) {
             aoData.push( { "name": "ocr", "value": true } );
         }
         var batch = $("#batch-filter").val();
         if (batch.length > 0) {
            aoData.push( { "name": "batch", "value": batch } );
         }
         var set = $("#set-filter").val();
         if (set.length > 0) {
            aoData.push( { "name": "set", "value": set } );
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
});