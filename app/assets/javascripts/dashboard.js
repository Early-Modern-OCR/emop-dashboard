/**
 * Main javascript file for the dashboard
 */

$(function() {
   
   var resultCell = function(nTd, data) {
      if ( data === "-" ) {
         return;
      }
      
      if ( data < 0.6 ) {
         $(nTd).addClass("bad-cell");
      } else if ( data < 0.8 ) {
         $(nTd).addClass("warn-cell");
      }
   };
   
   $('#detail-table').dataTable( {
      "sPaginationType": "full_numbers",
      "bPaginate": true,
      "bProcessing": true,
      "bServerSide": true,
      "sAjaxSource": "dashboard/fetch",
      "sAjaxDataProp": "data",
      "aoColumnDefs": [
         // center all of the jx/retas results
         { "aTargets": [4], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [5], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [6], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [7], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [8], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [9], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [10], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [11], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
      ]
   });
});