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
      if ( data.length === 0 ) {
         $(nTd).removeClass("bad-cell");
         $(nTd).removeClass("warn-cell");
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
      "bProcessing": true,
      "bServerSide": true,
      "sAjaxSource": "dashboard/fetch",
      "sAjaxDataProp": "data",
      //"bFilter": false,
      //"sDom": '<"top"l>rt<"bottom"ip><"clear">',
      "aoColumnDefs": [
         { "aTargets": [4], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [5], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [6], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} },
         { "aTargets": [7], "sClass": "result-data", "fnCreatedCell": function (nTd, sData, oData, iRow, iCol) { resultCell(nTd,sData);} }
      ]//,
      //"fnServerParams": function ( aoData ) {
      //   aoData.push( { "name": "tcp_filter", "value":  $("#tcp-filter").val()  } );
    //}
   }).fnFilterOnReturn();
});