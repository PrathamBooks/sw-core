function StoryEditor(page, service){
  var EVERY_MINUTE = 10 * 1000;
  var prevoius_page_id;
  var prevoius_content;
  var current_page_id;
  var current_content;

  var create_textbox = function(){
    var page_id = page.page_id();
    service.create_textbox(page_id, page.getQuery());
  }

  var save = function(page_id) {
    var textbox_param = page.textbox_id() ? $.param({textbox_id: page.textbox_id()}) : null;
    var contents = (page.contents() || '').trim();
    if(!contents) {
      return;
    }
    var data = {
      page: {
        content: contents
      }
    };
    current_content = contents;
    current_page_id = page.page_id();
    if(prevoius_page_id == current_page_id && prevoius_content == current_content){
      return
    }
    service.save_contents(page_id || page.page_id(), data, textbox_param);
    prevoius_content = contents;
    prevoius_page_id = page.page_id();

    page.update_last_saved_time(new Date().toLocaleTimeString(navigator.language, {hour: '2-digit', minute:'2-digit', hour12: true}));
  };
  var save_on_blur = function(page_id) {
    var textbox_param = page.textbox_id() ? $.param({textbox_id: page.textbox_id()}) : null;
    if (disable_blur) {
      return;
    }
    var contents = (page.contents() || '').trim();
    if(!contents) {
      return;
    }
    var data = {
      page: {
        content: contents
      }
    };

    service.save_contents_on_blur(page_id || page.page_id(), data, textbox_param);
    page.update_last_saved_time(new Date().toLocaleTimeString(navigator.language, {hour: '2-digit', minute:'2-digit', hour12: true}));
  };

  var init_auto_save = function(){
    if (timer_id == 0) {
      timer_id = setInterval(save, EVERY_MINUTE);
    }
  };

  var remove_auto_save = function(){
    clearInterval(timer_id);
    timer_id = 0;
  };

  var blu_call_disable = function(){
    disable_blur = true
  };

  // var init_illustration_drawer = function(){
  //   page.illustrations_click(service.update_page_illustration);
  // };

  var init_template_drawer = function(){
    page.templates_click(service.change_page_template);
  };

  var is_current_page_story_page = function(classes){
    return classes.indexOf('StoryPage') != -1;
  };

  var is_current_page_front_cover_page = function(classes){
    return classes.indexOf('FrontCoverPage') != -1;
  };

  var is_current_page_back_cover_page = function(classes){
    return classes.indexOf('BackCoverPage') != -1;
  };

  var hide_illustration_drawer_based_on_orientation = function(){
    if(page.is_page_template_is_full_text_vertical_template() ||
       page.is_page_template_is_full_text_horizontal_template() ||
       is_current_page_back_cover_page($('.page.active').attr("class"))
      ){
        $("#open_image_drawer").addClass('disabled')
        document.getElementById('open_image_drawer').style.pointerEvents = 'none';
    }else if (!page.is_derivation())
    {    $("#open_image_drawer").removeClass('disabled')
        document.getElementById('open_image_drawer').style.pointerEvents = 'auto';}
  };

  var setup_page_manipulation_links = function (classes){
    if(is_current_page_back_cover_page(classes)){
      page.disable_page_manipulation_links();
      return;
    }

    if(page.is_derivation()) {
      $("#open_image_drawer").addClass('disabled')
      document.getElementById('open_image_drawer').style.pointerEvents = 'none';
      
      if(is_current_page_story_page(classes)) {
        page.enable_page_manipulation_links_for_derivation();
      } else {
        page.disable_page_manipulation_links();
      }
    } else {

      if(is_current_page_story_page(classes)) {
        page.enable_page_manipulation_links();
      } else {
        page.disable_page_manipulation_links();
      }
    }

  };

  var init_page_rearrange = function(){
    // if(page.is_derivation()) {
    //   return;
    // }
    page.rearrange(function(classes, story_id, data){
      save_on_blur();
      blu_call_disable();
      remove_auto_save();
      setup_page_manipulation_links(classes);
      service.rearrange_page(story_id, data);
    });
  };

  var init_page_click = function(){
    page.click(function(classes, pageId){
        console.log(classes)
      save_on_blur();
      blu_call_disable();
      remove_auto_save();
      setup_page_manipulation_links(classes);
      service.page_edit(pageId)
    });
  };

  var init_page_editor_click = function(){
    page.click_editor(function(pageId, query){
      save_on_blur();
      blu_call_disable();
      remove_auto_save();
      if (pageId){
        return service.set_page_editor(pageId, query);
      }
    });
  }


  var init_page_textbox_resize_drag = function(){
    page.textbox_resize_drag(function(pageId, textboxId, query, data){
      save(pageId);
      service.update_textbox(pageId, textboxId, query, data);
    });
  }

  var init_page_textbox_trash = function(content){
    page.destroy_textbox(function(pageId, textboxId, query){
      if (pageId && textboxId){
        service.destroy_textbox(pageId, textboxId, query);
      }
    }, content);
  }

  var init_page_textbox_change_color = function(){
    page.background_color(function(pageId, textboxId, query, data){
       service.update_textbox(pageId, textboxId, query, data);
    });
  }

  var init_page_textbox_set_border = function(){
    page.set_textbox_border(function(pageId, textboxId, query, data) {
      service.update_textbox(pageId, textboxId, query, data);
    });
  }

  var init_page_manipulation_links = function(){
    page.insert_page_click(service.insert_page);
    page.delete_page_click(service.delete_page);
    page.duplicate_page_click(service.duplicate_page);
  };

  var init_publish_link = function(){
    var publish = page.is_derivation() ? service.publish.bind(this) : service.open_story_card_croppic.bind(this);
    page.init_publish_link(function(story_id){
      service.validate_story_pages(story_id);
    }, publish);
  };

  var publish_story = function(image_errors, orientation_errors){
    service.publish(page.story_id());
  };

  var handle_story_page_validation_errors = function(image_errors, orientation_errors, textbox_errors){
    if(image_errors.length !== 0 || orientation_errors.length !== 0|| textbox_errors !== "") {
      page.display_story_page_validation_errors(image_errors, orientation_errors, textbox_errors);
      return;
    }
    if (page.is_derivation()){
      service.publish(page.story_id());
    }
    else {
      service.open_story_card_croppic(page.story_id());
    }
  };

  var set_story_card_view = function(illustration_id, page_id, image_width, image_height){
    page.set_storycard_view(service.set_story_card_image, illustration_id, page_id, { width: image_width, height: image_height });
  };

  var init_publish_story_form = function(){
    page.init_publish_story_form(service.publish_story);
  };

  var init_edit_book_info_link = function(){
    page.init_edit_book_info(service.edit_book);
  };

  var init_original_text = function(){
    page.init_original_text();
  };

  var init_page_controls_click = function(){
    page.previous_page_click();
    page.next_page_click();
    page.add_page_click(service.insert_page);
    page.page_controll_links_visibility();
  };

  var init_cannot_edit_front_cover_dialog = function(){
    page.init_cannot_edit_front_cover_dialog();
  };

  var init = function(){
    init_page_manipulation_links();
    init_publish_link();
    init_edit_book_info_link();
  };

  return {
    init: init,
    save: save,
    create_textbox: create_textbox,
    init_page_rearrange: init_page_rearrange,
    init_template_drawer: init_template_drawer,
    init_page_click: init_page_click,
    handle_story_page_validation_errors: handle_story_page_validation_errors,
    publish_story: publish_story,
    init_publish_story_form: init_publish_story_form,
    init_original_text: init_original_text,
    setup_page_manipulation_links: setup_page_manipulation_links,
    set_pages_ribbon_width: page.set_pages_ribbon_width,
    hide_illustration_drawer_based_on_orientation: hide_illustration_drawer_based_on_orientation,
    init_cannot_edit_front_cover_dialog: init_cannot_edit_front_cover_dialog,
    save_on_blur: save_on_blur,
    init_auto_save: init_auto_save,
    init_page_controls_click: init_page_controls_click,
    init_page_editor_click: init_page_editor_click,
    init_page_textbox_resize_drag: init_page_textbox_resize_drag,
    init_page_textbox_trash: init_page_textbox_trash,
    init_page_textbox_change_color: init_page_textbox_change_color,
    init_page_textbox_set_border: init_page_textbox_set_border, 
    set_story_card_view: set_story_card_view 
  };
}
