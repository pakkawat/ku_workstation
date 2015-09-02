var interval;
$(document).ready(function () {
    // will call refreshPartial every 3 seconds
    //var interval = setInterval(refreshPartial, 3000)
    if(interval){
      clearInterval(interval);
      //interval = setInterval(refreshPartial, 3000)
    }
    interval = setInterval(refreshPartial, 3000)


// calls action refreshing the partial
function refreshPartial() {
  $.ajax({
    url: "refresh_part",
    error: function(){
        clearInterval(interval);
        interval = null;
    }
 })
}

});