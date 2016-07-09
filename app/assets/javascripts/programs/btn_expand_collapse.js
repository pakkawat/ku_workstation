$(document).off("click", 'a[href="#"]').on("click", 'a[href="#"]', function(e) {
    e.preventDefault();
    $header = $(this);
    //getting the next element
    //$content = $header.prev();
$content = $header.parents(".form-group").next();
    //open up the content needed - toggle the slide- if visible, slide up, if not slidedown.
    $content.slideToggle(500, function () {
        //execute this after slideToggle is done
        //change text of header based on visibility of content div
        $header.text(function () {
            //change text based on condition
            return $content.is(":visible") ? "Collapse" : "Expand";
        });
    });

});
