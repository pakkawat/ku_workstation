$(document).ready(function () {
    // will call refreshPartial every 3 seconds
    setInterval(refreshPartial, 1000)

});

// calls action refreshing the partial
function refreshPartial() {
  $.ajax({
    url: "refresh_part"
 })
}