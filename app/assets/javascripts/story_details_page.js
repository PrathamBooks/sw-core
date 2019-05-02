function StoryDetailsPage(){
  var translate_form = $('.translate_story');
  var relevel_form = $('.relevel_story');

  var init_ajax_form = function(form_element){
    form_element.ajaxForm({
      dataType:  'script',
      beforeSubmit: $.blockUI,
      success: function(responseText){
        if(!(/window\.location\.href/.test(responseText))){
          $.unblockUI();
       } 
      },
      error: function(e){
        $.unblockUI();
        alert('There was an error while processing your action, please retry after some time.');
      }
    });
  };

  var init_translate_story_form = function(){
    init_ajax_form(translate_form);
  };

  var init_relevel_story_form = function(){
    init_ajax_form(relevel_form);
  };

  return {
    init_translate_story_form: init_translate_story_form,
    init_relevel_story_form: init_relevel_story_form
  }
}
