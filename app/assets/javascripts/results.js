
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
      "bSortClasses": false,
      "sAjaxSource": "/results/fetch?work="+work_id+"&batch="+batch_id,
      "sAjaxDataProp": "data",
      "aaSorting": [],
      "aoColumnDefs": [
         { "aTargets": [0], "bSortable": false}
      ],
      "aoColumns": [
         { "mData": "detail_link" },
         { "mData": "page_number" },
         { "mData": "juxta_accuracy" },
         { "mData": "retas_accuracy" },
         { "mData": "page_image" }
       ]
   }).fnFilterOnReturn();
   
   $("#results-detail").on("click", ".detail-link", function() {
      showWaitPopup("Visualizing");
   });
});