$(document).ready(function() {

    $('#programs').dataTable().fnDestroy();

    $('#programs').DataTable( {
        initComplete: function () {
            var i = 0;
            this.api().columns().every( function () {
                var column = this;
                if(i == 1){
                  var select = $('<select id="program_owner_name" class="form-control input-sm"><option value=""></option></select>')
                      .appendTo( $(column.footer()).empty() )
                      .on( 'change', function () {
                          var val = $.fn.dataTable.util.escapeRegex(
                              $(this).val()
                          );

                          column
                              .search( val ? '^'+val+'$' : '', true, false )
                              .draw();
                      } );

                  column.data().unique().sort().each( function ( d, j ) {
                      if(gon.ku_user_name == d){
                        select.append( '<option value="'+d+'" selected>'+d+'</option>' )
                      }else{
                        if(d != ""){
                          select.append( '<option value="'+d+'">'+d+'</option>' )
                        }
                      }
                  } );
                }else{
                  $(column.footer()).empty();
                }
                i = i + 1;
            } );
        }
    } );

$('#program_owner_name').trigger('change');

} );
