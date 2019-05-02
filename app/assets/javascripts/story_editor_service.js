function StoryEditorService(){

  var ajax_call = function(url, type){
    return $.ajax({
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

  var create_textbox = function(page_id, query){
    console.log("Create textbox on Page " + page_id);
    query = query ? '?' + query : '';
    url = '/v0/editor/page/' + page_id + '/create_textbox' + query;
    ajax_call(url, 'GET');
  }

  var save_contents = function(page_id, data, textbox_param){
    console.log("Auto save on page "+page_id);
    var query = textbox_param ? '?' + textbox_param : '';
    url = '/v0/editor/page/'+ page_id +'/auto_save_content' + query;
    $.post(url, data, null, 'script');
  };

  var save_contents_on_blur = function(page_id, data, textbox_param){
      console.log("Blur save on page "+page_id);
      var query = textbox_param ? '?' + textbox_param : '';
      url = '/v0/editor/page/'+ page_id +'/save_content_on_blur' + query;
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

  var set_page_editor = function(page_id, query){
    query = query ? '?' + query : '';
    return ajax_call('/v0/editor/page_editor/'+ page_id + query, 'GET');
  }

  var update_textbox = function(page_id, textbox_id, query, data){
    query = query ? '?' + query : '';
    url = "/v0/editor/page_editor/" + page_id + "/textbox/" + textbox_id + query;
    $.post(url, { textbox: data }, null, 'script');
  }

  var destroy_textbox = function(page_id, textbox_id, query){
    query = query ? '?' + query : '';
    url = "/v0/editor/page_editor/page/" + page_id + "/textbox/" + textbox_id + query;
    ajax_call(url, 'DELETE');
  }
  
  var validate_story_pages = function(story_id){
    $.ajax({ 
      url: '/v0/editor/story/'+ story_id+'/validate_pages/', 
      type: 'GET',
      error: function(e){
        alert('There was an error while processing your action, please retry after some time.');
      },
      dataType: 'script'
    });
  }

  var open_story_card_croppic = function(story_id) {
    ajax_call('/v0/editor/story/' + story_id + '/storycard_crop/', 	  'GET'); 
  }

  var set_story_card_image = function(illustration_id, page_id, image_dimensions){
      var url = "/v0/editor/" + page_id + "/crop/" + illustration_id
      $.ajax({
       type: 'POST',
       url: url,
       data: image_dimensions,
       beforeSend: $.blockUI,
       success: $.unblockUI,
       error: function(e){
	 $.unblockUI();
	 alert('There was an error while processing your action, please retry after some time.');
       },
       dataType: 'script'
     });
     console.log(image_dimensions);
  }

  var publish = function(story_id){
    ajax_call('/v0/editor/story/'+ story_id+'/publish/',
        'GET');
  };
  var edit_book = function(story_id){
    ajax_call('/v0/editor/story/'+ story_id+'/edit_book_info/', 'GET');
  };

  return {
      create_textbox: create_textbox,
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
      edit_book: edit_book,
      set_page_editor: set_page_editor,
      update_textbox: update_textbox,
      destroy_textbox: destroy_textbox,
      open_story_card_croppic: open_story_card_croppic,
      set_story_card_image:set_story_card_image 
  };
}
