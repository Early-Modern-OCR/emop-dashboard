
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
      "sAjaxSource": "results/fetch?work="+work_id+"&batch="+batch_id,
      "sAjaxDataProp": "data",
      "aaSorting": [],
      "aoColumnDefs": [
         { "aTargets": [0], "bSortable": false},
         { "aTargets": [1], "bSortable": false},
         { "aTargets": [2], "bSortable": false},
         { "aTargets": [3], "bSortable": false}
      ],
      "aoColumns": [
         { "mData": "page_select" },
         { "mData": "status" },
         { "mData": "detail_link" },
         { "mData": "page_image" },
         { "mData": "page_number" },
         { "mData": "juxta_accuracy" },
         { "mData": "retas_accuracy" },
       ]
   }).fnFilterOnReturn();
   
   $("#results-detail").on("click", ".detail-link", function() {
      showWaitPopup("Visualizing");
   });
});