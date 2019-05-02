jQuery(function($) {'use strict',

  //#main-slider
  $(function(){
    $('#main-slider.carousel').carousel({
      interval: 8000
    });
  });


  // accordian
  $('.accordion-toggle').on('click', function(){
    $(this).closest('.panel-group').children().each(function(){
    $(this).find('>.panel-heading').removeClass('active');
     });

    $(this).closest('.panel-heading').toggleClass('active');
  });

  //Initiat WOW JS
  new WOW().init();

  //goto top
  $('.gototop').click(function(event) {
    event.preventDefault();
    $('html, body').animate({
      scrollTop: $("body").offset().top
    }, 500);
  });

  $.cookie('_w', $(window).width(), { path: '/' });
  $.cookie('_h', $(window).height(), { path: '/' });
});
// For Modal pop's backdrop alignment
$( window ).on( 'mousemove mouseup', function() {
  var $modal     = $('.modal-dialog')
    , $backdrop  = $('.modal-backdrop')
    ,el_height   = null;

  var selectedModal = null
  var tempObject = null
  if ($modal.length > 1) {
    for (var i = 0; i < $modal.length; i++) {
      tempObject = $modal[i]
      if (tempObject.scrollHeight > 0) {
        selectedModal = $modal[i]
      }
    }
  }
  if (selectedModal != null) {
    el_height  = selectedModal.scrollHeight;
  } else {
    el_height = $modal.innerHeight();
  }
  $backdrop.css({
      height: el_height + 120,
      minHeight: '100%',
      margin: 'auto'
  });
});

$( document ).ajaxError(function(e, xhr, status, error) {
  if(xhr.status == 401){
    window.location.href = "/users/sign_in";
  }   
  var msg = xhr.getResponseHeader('X-Message');
  if (msg) alert(msg);
});

$( document ).ready(function() {
  document.documentElement.setAttribute("data-browser", navigator.userAgent);
})
