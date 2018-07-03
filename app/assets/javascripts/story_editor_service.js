function StoryEditorService(){

  var ajax_call = function(url, type){
     $.ajax({
      type: type,
      url: url,
      beforeSend: $.blockUI,
      success: $.unblockUI,
      error: function(e){
        $.unblockUI();
        alert('There was an error while processing your action, please retry after some time.');
      },
      dataType: 'script'
    });
  };

  var save_contents = function(page_id, data){
    console.log("Auto save on page "+page_id);
    url = '/v0/editor/page/'+ page_id +'/auto_save_content';
    $.post(url, data, null, 'script');
  };

  var save_contents_on_blur = function(page_id, data){
      console.log("Blur save on page "+page_id);
      url = '/v0/editor/page/'+ page_id +'/save_content_on_blur';
      $.post(url, data, null, 'script');
  };

    // var update_page_illustration = function(page_id, illustration_id){
  //   ajax_call('/editor/page/'+ page_id +'/illustration/?page[illustration_id]='+ illustration_id,
  //       'POST');
  // };

  var change_page_template = function(page_id, page_template_id){
    ajax_call('/v0/editor/page/'+ page_id +'/change_template/'+ page_template_id,
        'PUT');
  };

  var insert_page = function(story_id, page_id, number_of_pages){
    ajax_call('/v0/editor/story/'+ story_id +'/insert/'+page_id+'?'+'number_of_pages='+number_of_pages,
        'PUT');
  };

  var delete_page = function(story_id, page_id){
    ajax_call('/v0/editor/story/'+ story_id+ '/delete/'+ page_id,
        'DELETE');
  };

  var duplicate_page = function(story_id, page_id){
    ajax_call('/v0/editor/story/'+ story_id + '/duplicate/'+ page_id,
        'PUT');
  };

  var rearrange_page = function(story_id, data){
    $.ajax({
      type: 'POST',
      url: '/v0/editor/story/'+ story_id + '/rearrange',
      data: data,
      beforeSend: $.blockUI,
      success: $.unblockUI,
      error: function(e){
        $.unblockUI();
        alert('There was an error while processing your action, please retry after some time.');
      },
      dataType: 'script'
    });
  };

  var page_edit = function(page_id){
    ajax_call('/v0/editor/page/'+ page_id,
        'GET');
  };

  var validate_story_pages = function(story_id){
    ajax_call('/v0/editor/story/'+ story_id+'/validate_pages/',
        'GET');
  }

  var publish = function(story_id){
    ajax_call('/v0/editor/story/'+ story_id+'/publish/',
        'GET');
  };
  var edit_book = function(story_id){
    ajax_call('/v0/editor/story/'+ story_id+'/edit_book_info/', 'GET');
  };

  return {
      save_contents: save_contents,
      save_contents_on_blur: save_contents_on_blur,
     // update_page_illustration: update_page_illustration,
      change_page_template: change_page_template,
      insert_page: insert_page,
      delete_page: delete_page,
      duplicate_page: duplicate_page,
      rearrange_page: rearrange_page,
      page_edit: page_edit,
      validate_story_pages: validate_story_pages,
      publish: publish,
      edit_book: edit_book
  };
}
