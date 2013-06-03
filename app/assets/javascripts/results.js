
$(function() {
  
   var work_id = $("#work-id").text();
   var batch_id = $("#batch-id").text();
   var resultTable = $('#pages-table').dataTable( {
      "bProcessing": true,
      "bServerSide": true,
      "bStateSave": false,
      "bPaginate": false,
      "bFilter": false,
      "bInfo": false,
      "sAjaxSource": "/results/fetch?work="+work_id+"&batch="+batch_id,
      "sAjaxDataProp": "data",
      "aoColumns": [
         { "mData": "page_number" },
         { "mData": "juxta_accuracy" },
         { "mData": "retas_accuracy" },
       ]
   }).fnFilterOnReturn();
});