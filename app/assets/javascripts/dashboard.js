/**
 * Main javascript file for the dashboard
 */

$(function() {
  $('#detail-table').dataTable( {
        "iDisplayLength": 100,
        "bProcessing": true,
        "bServerSide": true,
        "sAjaxSource": "dashboard/fetch",
        "sAjaxDataProp": "data",
        "aoColumnDefs": [
            // center all of the jx/retas results
            { "sClass": "result-data", "aTargets": [ 4 ] },
            { "sClass": "result-data", "aTargets": [ 5 ] },
            { "sClass": "result-data", "aTargets": [ 6 ] },
            { "sClass": "result-data", "aTargets": [ 7 ] },
            { "sClass": "result-data", "aTargets": [ 8 ] },
            { "sClass": "result-data", "aTargets": [ 9 ] },
            { "sClass": "result-data", "aTargets": [ 10 ] },
            { "sClass": "result-data", "aTargets": [ 11 ] } 
        ]
    } );
});