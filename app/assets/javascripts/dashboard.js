/**
 * Main javascript file for the dashboard
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
 
   $('#detail-table').dataTable( {
      "iDisplayLength": 25,
      "bProcessing": true,
      "bServerSide": true,
      "sAjaxSource": "dashboard/fetch",
      "sAjaxDataProp": "data",
      "fnCreatedRow": function( nRow, aData, iDisplayIndex ) {
         if ( aData.ocr_engine === "Gale" ) {
             $(nRow).addClass("gale-row");            
         }
      },
      "aoColumns": [
         { "mData": "data_set" },
         { "mData": "tcp_number" },
         { "mData": "title" },
         { "mData": "author" },
         { "mData": "ocr_date" },
         { "mData": "ocr_engine" },
         { "mData": "ocr_batch" },
         { "mData": "juxta_url" },
         { "mData": "retas_url" },
       ],
      "aoColumnDefs": [
         { "aTargets": [0], "bSortable": false},
         { "aTargets": [6], "bSortable": false},
         { "aTargets": [7], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [8], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} }
      ]
   }).fnFilterOnReturn();
});