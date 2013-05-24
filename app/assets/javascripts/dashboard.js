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
      "iDisplayLength": 25,
      "bPaginate": true,
      "bProcessing": true,
      "bServerSide": true,
      "sAjaxSource": "dashboard/fetch",
      "sAjaxDataProp": "data",
      "aoColumnDefs": [
         { "aTargets": [4], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [5], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [6], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [7], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} }
      ]
   });
});