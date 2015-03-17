// Pop 

$('.himg a').click(function(e){
   e.preventDefault();
   var foo = $(this).attr('class');
   $('.popy').slideUp({
   duration : 400,
   easing : 'easeOutQuint'
   }).delay(300);
   $('.pop'+foo).slideDown({
   duration : 400,
   easing : 'easeInQuint'
   });
});

// prettyPhoto

jQuery("a[class^='prettyPhoto']").prettyPhoto({
overlay_gallery: false, social_tools: false
});

// Twitter 

jQuery(function($){
   $(".tweet").tweet({
      username: "ashobiz",
      join_text: "auto",
      avatar_size: 0,
      count: 2,
      auto_join_text_default: "we said,",
      auto_join_text_ed: "we",
      auto_join_text_ing: "we were",
      auto_join_text_reply: "we replied to",
      auto_join_text_url: "we were checking out",
      loading_text: "loading tweets...",
      template: "{text}"
   });
}); 

// Tooltip

$('.tip').tooltip();

// Isotype

// cache container
var $container = $('#portfolio');
// initialize isotope
$container.isotope();

// filter items when filter link is clicked
$('#filters a').click(function(){
  var selector = $(this).attr('data-filter');
  $container.isotope({ filter: selector });
  return false;
});