function remove_fields(link) {  
    $(link).prev("input[type=hidden]").val("1");  
    $(link).closest(".form-group").hide();  
}  

function remove_panel_info(link) {  
    $(link).prev("input[type=hidden]").val("1");  
    $(link).closest(".panel panel-info").hide();  
}  
  
function add_fields(link, association, content) {  
    var new_id = new Date().getTime();  
    var regexp = new RegExp("new_" + association, "g");  
    $(link).first().after(content.replace(regexp, new_id));  
}
