function StoryDetails(page){
  var init_translate_story_form = function(){
    page.init_translate_story_form();
  };

  var init_relevel_story_form = function(){
    page.init_relevel_story_form();
  };

  return {
    init_translate_story_form: init_translate_story_form,
    init_relevel_story_form: init_relevel_story_form
  }
}
