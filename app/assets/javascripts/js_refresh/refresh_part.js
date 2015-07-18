$(document).ready(function () {
    // will call refreshPartial every 2 seconds
    setInterval(refreshPartial, 2000)

});

// calls action refreshing the partial
function refreshPartial() {
  $.ajax({
    url: "refresh_part"
 })
}