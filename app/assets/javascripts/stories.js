function stories_init() {
  var carousel = $(".carousel");

  var init_carousel = function() {
    $(".carousel").carousel();
  };

  var handle_window_resize = function(){
    $(window).resize(function () {
      init_carousel();
    });
  };

  var toggle_versions_section = function(){
    var state1 = false;
    $(".toggle-slide-drop").click(function () {
    	$(".cate-story h2").removeClass("new-content");
    	$(".stry-ctg").css("display", "none");
      var height = $(window).height();
      if (!state1) {
        $('.stry-drop').animate({"right":"0px",width: "toggle"}, 200);
        $(".toggle-slide-drop h2").addClass("new-content");
        state1 = true;
      }
      else {
        $('.stry-drop').animate({"right":"0px",width: "toggle"}, 200);
        $(".toggle-slide-drop h2").removeClass("new-content");
        state1 = false;
      }
    });
  };

  var toggle_catetogies_section = function(){
    var state2 = false;
    $(".cate-story").click(function () {
      if (!state2) {
        $('.stry-ctg').animate({"right":"0px",width: "toggle"}, 200);
        $(".cate-story h2").addClass("new-content");
        state2 = true;
      }
      else {
        $('.stry-ctg').animate({"right":"0px",width: "toggle"}, 200);
        $(".cate-story h2").removeClass("new-content");
        state2 = false;
      }
    });
  };

  toggle_versions_section();
  toggle_catetogies_section();
  handle_window_resize();
}
