var ready, set_positions;

set_positions = function(){
    // loop through and give each task a data-pos
    // attribute that holds its position in the DOM
    $('.row.chef-resource').each(function(i){
        $(this).attr("data-pos",i+1);
    });
}

ready = function(){

    // call set_positions function
    set_positions();

    // call sortable on our div with the sortable class
    $('.sortable').sortable();

    // after the order changes
    $('.sortable').sortable().bind('sortupdate', function(e, ui) {

        // array to store new order
        updated_order = []
        // set the updated positions
        set_positions();

        // populate the updated_order array with the new task positions
        $('.row.chef-resource').each(function(i){
            updated_order.push({ id: $(this).data("id"), position: i+1 });
        });

        // send the updated order via ajax
        $.ajax({
            type: "PUT",
            url: '/programs/sort',
            data: { program_id: document.getElementById("program_id").value, order: updated_order },
            error: function(xhr, status, error){
              alert(xhr.responseText);
            }
        });
    });

}

$(document).ready(ready);
/**
 * if using turbolinks
 */
$(document).on('page:load', ready);
