function StoryEditorPage(){
  var insert_page_link = $('#insert_page');
  var delete_page_link = $('#delete_page');
  var duplicate_page_link = $('#duplicate_page');
  var create_textbox = $('#create-textbox');
  var delete_page_dialog = $("#delete_page_dialog");
  var storycard_edit_image_done = $('#storycard-img-edit-done');
  var delete_last_story_page_dialog = $("#delete_last_story_page_dialog");
  var story_page_validation_errors_dialog = $("#story_page_validation_errors_dialog");
  var story_page_validation_image_errors = $("#story_page_validation_errors_dialog #image_errors");
  var story_page_validation_textbox_warnings = $("#story_page_validation_textbox_warnings_dialog");
  var story_page_textbox_delete_warning =$('#story_page_textbox_delete_warning');
  var story_page_validation_orientation_errors = $("#story_page_validation_errors_dialog #orientation_errors");
  var authors_preview_text = $('#review_book_covers').find('.authors');
  var cannot_edit_front_cover_dialog = $("#cover_title_click_dialog");
  var front_cover_title = $(".right-side-editor .cover_title");
  var title_preview_text = $('#review_book_covers').find('.cover_title');
  var back_cover_title_preview_text = $('#review_book_covers').find('.back_cover_title');
  var synopsis_preview_text = $('#review_book_covers').find('.synopsis');
  var reading_level_preview_text = $('#review_book_covers').find('.book-levels');
  var publisher_logo = $('#review_book_covers').find('.publisher-logo');
  var back_cover_reading_level_preview_text = $('#review_book_covers').find('.reading_level_help');
  var author_form_fields = $(".fields");
  var author_first_name_selector = '.story_authors_first_name input';
  var author_last_name_selector = '.story_authors_last_name input';
  var publish_form = $('.publish_story');
  var previous_page_link = $('#previous_page');
  var next_page_link = $('#next_page');
  var add_page_link = $("#add_page");

  var page_id = function(){
    return $('.page.active a').data('page-id');
  };

  var story_id = function(){
    return $('.page.active a').data('story-id');
  };

  var language = function(){
    return $('.page.active a').data('language');
  };

  var contents = function(){
    return $("#txtEditor").html();
  };

  var is_derivation = function(){
    return $('.page.active a').data('is-derivation');
  };

  var is_last_story_page = function(){
    return $("#sortable").find("div.StoryPage").length == 1;
  };

  var textbox_id = function(){
    return $("#txtEditor").parent().data('textboxId');
  }

  var update_last_saved_time = function(time){
    $('#last_saved_time_label').text("Last saved at");
    $('#last_saved_time').text(time.toUpperCase());
  };

  // var illustrations_click = function(on_illustration_click){
  //   $('.illustration_drawer_img').click(function(){
  //     on_illustration_click(page_id(), $(this).data('illustrationId'));
  //   });
  // };

  var story_orientation = function(){
    return $('#myTabContent').data('storyOrientation');
  };

  var update_story_orientation = function(newOrientation){
    return $('#myTabContent').data('storyOrientation', newOrientation);
  };

  var is_page_template_is_full_text_vertical_template = function(){
    return $('.page.active').find(".illustration").hasClass("sp_v_c100");
  };

  var is_page_template_is_full_text_horizontal_template = function(){
    return $('.page.active').find(".illustration").hasClass("sp_h_c100");
  };

  var templates_click = function(on_template_click){
    $('.page-template').click(function(evt){
      var selected_template = $(this);
      if(selected_template.data('templateOrientation') != story_orientation()){
        evt.preventDefault();
        var dialogElement = $("#change_orientation_dialog");
        dialogElement.data('pageTemplateId', selected_template.data('pageTemplateId'));
        dialogElement.data('newOrientation', selected_template.data('templateOrientation'));
        dialogElement.dialog("open");
      } else {
        on_template_click(page_id(), selected_template.data('pageTemplateId'));
      }
    });

    $("#change_orientation_dialog").dialog({
      autoOpen: false,
      width: 600,
      modal: true,
      buttons : {
        "Confirm" : function() {
          var dialogElement = $(this);
          dialogElement.dialog("close");
          update_story_orientation(dialogElement.data('newOrientation'));
          on_template_click(page_id(), dialogElement.data('pageTemplateId'));
        },
      	"Cancel" : function() {
        $(this).dialog("close");
      	}
      },
      dialogClass: 'change_orientation_dialog'
    });
  };

  var insert_page_click = function(on_insert_page_click){
    insert_page_link.click(function(){
        var number_of_pages = $("#numberOfPages").val()
      on_insert_page_click(story_id(), page_id(), number_of_pages);
    });
  };

  var add_page_click = function(on_add_page_click){
    add_page_link.click(function(){
      on_add_page_click(story_id(), page_id(), 1);
    });
  };

  var delete_page_click = function(on_delete_page_click){
    delete_page_link.click(function(evt){
      evt.preventDefault();
      if(is_last_story_page())
        { 
          delete_last_story_page_dialog.html("You cannot remove this page");
          delete_last_story_page_dialog.dialog("open");
        }
      else
        {
          delete_page_dialog.html("Are you sure you want to remove page?");
          delete_page_dialog.dialog("open");
        }
    });

    delete_page_dialog.dialog({
      autoOpen: false,
      width: 400,
      modal: true,
      buttons : {
        "Confirm" : function() {
          $(this).dialog("close");
          on_delete_page_click(story_id(), page_id());
        },
      	"Cancel" : function() {
          $(this).dialog("close");
      	}
      },
      dialogClass: 'change_orientation_dialog'
    });

    delete_last_story_page_dialog.dialog({
      autoOpen: false,
      width: 300,
      modal: true,
      buttons : {
      "Ok" : function() {
        $(this).dialog("close");
        }
      },
        dialogClass: 'change_orientation_dialog'     
      });
  };

  var duplicate_page_click = function(on_duplicate_page_click){
    duplicate_page_link.click(function(){
      on_duplicate_page_click(story_id(), page_id());
    });
  };

  var set_pages_ribbon_width = function(){
    var width = 0;
    $('.p-holder .page-list .page').each(function() {
      width += $(this).outerWidth( true );
    });
    $('.p-holder .page-list').css('width', width + "px");
  };

  var rearrange = function(on_rearrange){
    set_pages_ribbon_width();
    $("#sortable").sortable();
    $("#sortable").on("sortbeforestop", function( event, ui ) {
      var selected_page = ui.item.find("a");
      var data = {
        page: {
          "page_id": selected_page.data().pageId,
      "position": ui.item.index()+2
        }
      };
      on_rearrange(selected_page.attr('class'), story_id(), data);
    });
  };

  var click = function(on_click){
    $('.page_thumbnail').click(function(){
      var clicked_page = $(this);
      if(clicked_page.parent("div").hasClass('active'))
        return false;
      else
        on_click(clicked_page.attr('class'), clicked_page.data('pageId'))
    });
  };

  var getQuery = function(textboxId){
    var pageType = $('.page-container-landscape, .page-container-portrait').data('pageType');
    var query_params = {};
    if (textboxId){
      query_params['textbox_id'] = textboxId;
    }
    if (pageType){
      query_params['page_type'] = pageType;
    }
    return $.param(query_params);
  }
  var click_editor = function(on_click){
    if(!textbox_id()) $('#create-textbox').removeClass('active');
    $('.txtEditor').click(function(){
      var clicked_editor = $(this);
      if (clicked_editor.attr('id') != "txtEditor") {
        var textboxId = clicked_editor.parent().data('textboxId');    
        var query = getQuery(textboxId);
        on_click( clicked_editor.parent().data('pageId'), query)

        if (textboxId){
          $('#create-textbox').addClass("active");
        } else {
          $('#create-textbox').removeClass("active");
        }
      } else {
        return false;
      } 
    });
  };


  var generate_position = function(){
    var bounds = $(this).position();
    var parent_width = parseFloat($(this).parent().width());
    var parent_height = parseFloat($(this).parent().height());
    if (parent_width == 0 || parent_height == 0)
      return {}
      
    var left_percentage = bounds.left * 100 / parent_width;
    var left_percentage = Math.round(left_percentage * 100) / 100;
    
    var top_percentage = bounds.top * 100 / parent_height;
    top_percentage = Math.round(top_percentage * 100) / 100;
    if (isNaN(left_percentage) || isNaN(top_percentage)){
      return {};
    }
    return { textbox_position_left: left_percentage + '%', textbox_position_top: top_percentage + '%' };
  }

  var update_textbox = function(update){
    var box = this.getBoundingClientRect();
    var width = box.width;
    var height = box.height;
    var width_length_is_zero = width == 0 || height == 0;

    var data = generate_position.call(this);
    if( !width_length_is_zero ){
      var width_percentage = 100 * width / parseFloat($('.story-page').width()) + '%';
      var height_percentage = 100 * height / parseFloat($('.story-page').height()) + '%';
      $(this).css("width", 'calc(' + width_percentage + ')' );
      $(this).css("height",'calc(' +  height_percentage + ')');
      data.textbox_width = width_percentage;
      data.textbox_height =  height_percentage;
    }

    var textboxId = $(this).data('textboxId');    
    var query = getQuery();

    update($(this).data('pageId'), textboxId, query, data);
  }

  var textbox_resize_drag = function(update){ 
    $('.text-box').each(function(index, item){
      TextboxResizeDrag(item, {
	  stop: update_textbox.bind(this, update),
	  parent: $('.story-page')[0]
      })
    });
  };
  

  var destroy_textbox = function(on_click, content){
    var selected_textbox;
    setTimeout(function(){
      $('#story_page_textbox_delete_warning').dialog({
      	autoOpen: false,
      	width: 450,
      	modal: true,
        dialogClass: "textbox_destroy_dialog",
      	buttons: {
      	  "Yes": function(){
      	    var click_editor = selected_textbox;
      	    var query_params = {};
      	    var textboxId = click_editor.parent().data('textboxId'); 
      	    var query = getQuery();
      	    on_click(click_editor.parent().data('pageId'), textboxId, query);
      	    $(this).dialog('close');
	    $('#create-textbox').removeClass('active');
      	  },      	  
          "Cancel": function(){
            $(this).dialog('close');
          }
      	}
      });
    }, 200);
    
    $('.textbox-delete').click(function(event){
       selected_textbox = $(this);
       $('#story_page_textbox_delete_warning').html(content);
       $('#story_page_textbox_delete_warning').dialog('open');  
    });
  };

  var set_color = function(value, animation_delay){
    $('#opacity-selector-input')[0].value = value; 

    if ( typeof animation_delay != "undefined" ){
      $('#selector-color').animate({width: value + '%'}, animation_delay);
    } else {
      $('#selector-color').css('width', value + '%');
    }
    $('#txtEditor').css('background-color', 'rgba(255, 255, 255, ' + value * 0.01 + ')');
  };

  var background_color = function(on_change){
    var textbox = $("#txtEditor").parent();
    var textboxId = textbox.data('textboxId');

    if (typeof textboxId  === "undefined"){
      $('.opacity-selector').slider({
        disabled: true
      });
      $('#opacity-selector-input').attr('disabled', true);
      return
    }

    var prevColor = $('#txtEditor').css('background-color');
    var value = $('#txtEditor').data('textboxOpacity'); 
    set_color(value);


    // 
    // On background opacity changing by input, supports/handles keypress, copy, paste
    // Modify slider, validate value between 0 to 100
    //
    $("#opacity-selector-input").keypress(function(e){
      if(isNaN(String.fromCharCode(e.which))) e.preventDefault();
      var index = this.selectionStart;
      var number = this.value.slice(0, index) + e.key + this.value.slice(index);
      if (number > 100) e.preventDefault();
    }).keydown(function(){
      // Updating the value after keydown event
      setTimeout(function(){
        var value = $(this).val();
        if (value <= 100){
          set_color(value, 200);
          $( ".opacity-selector" ).slider( "value", value );
        }
      }.bind(this));
    }).change(function(event){
      if(!this.value) this.value = '0';
      if(this.value > 100) this.value = '100';
      var query = getQuery(textboxId);
      var data = {'background_color': this.value};
      on_change($(textbox).data('pageId'), textboxId, query, data);
    });

    // 
    // Background Opacity changing through JQuery Slider
    // On Change update input box
    //

    $( ".opacity-selector" ).slider({
      value: value,
      animate: "fast",
      slide: function( event, ui ){
        set_color(ui.value, 0);
      },
      stop: function( event, ui){
        var query = getQuery(textboxId);
        var data = { 'background_color': ui.value };
        on_change($(textbox).data('pageId'), textboxId, query, data);
      }
    });


  };

  var set_textbox_border = function(on_change){

    var textbox = $("#txtEditor").parent();
    var textboxId = textbox.data('textboxId');

    if (typeof textboxId  === "undefined"){
      $('#textbox-border').attr('disabled', true);
      return
    }

    $('#textbox-border').attr('checked', $('#txtEditor').data('textboxBorder'));

    $('#textbox-border').click(function(){
      var data = {
        boundary: this.checked
      };
      var query = getQuery(textboxId);
      on_change($(textbox).data('pageId'), textboxId, query, data);
    });

  }

  var disable_page_manipulation_links = function(){
    insert_page_link.addClass('disabled');
    delete_page_link.addClass('disabled');
    duplicate_page_link.addClass('disabled');
    $("#insert_pages").addClass('disabled');
    document.getElementById('insert_page').style.pointerEvents = 'none';
    document.getElementById('insert_pages').style.pointerEvents = 'none';
    document.getElementById('duplicate_page').style.pointerEvents = 'none';
    document.getElementById('delete_page').style.pointerEvents = 'none';
    create_textbox.addClass('disabled');
    document.getElementById('create-textbox').style.pointerEvents = 'none';
    $('#create-textbox').removeClass('active');
  };


  var enable_textbox_create_button = function(){
    if(is_derivation()) return;
    document.getElementById('create-textbox').style.pointerEvents = 'auto';
    create_textbox.removeClass('disabled');
  }

  var enable_page_manipulation_links = function(){
    insert_page_link.removeClass('disabled');
    delete_page_link.removeClass('disabled');
    duplicate_page_link.removeClass('disabled');
    $("#insert_pages").removeClass('disabled');
    document.getElementById('insert_page').style.pointerEvents = 'auto';
    document.getElementById('insert_pages').style.pointerEvents = 'auto';
    document.getElementById('duplicate_page').style.pointerEvents = 'auto';
    document.getElementById('delete_page').style.pointerEvents = 'auto';
    enable_textbox_create_button(); 
  };

  var enable_page_manipulation_links_for_derivation = function(){
    if (document.getElementById('open_image_drawer') != null) {
      document.getElementById('open_image_drawer').style.pointerEvents = 'none';}
    document.getElementById('insert_page').style.pointerEvents = 'none';
    document.getElementById('duplicate_page').style.pointerEvents = 'auto';
    document.getElementById('delete_page').style.pointerEvents = 'auto';
    delete_page_link.removeClass('disabled');
    duplicate_page_link.removeClass('disabled');
    enable_textbox_create_button(); 
  };

  var set_storycard_view = function(on_edit, illustration_id, page_id, image_geometry){

    storycard_edit_image_done.on('click', function() {
      var width =   $('#storycard-img').width();
      var height = $('#storycard-img').height();
      var url  = $('#storycard-img').attr('src');
      var scale = $('#storycard-img').data('scale');

      //compute width, height
      var width_px = $('#storycard-cropper').width() ;
      var height_px = $('#storycard-cropper').height();

      var template_width = 156;
      var template_height = 151;

      var ratio_x = template_width / width_px;
      var ratio_y = template_height / height_px;
      
      // compute position_x, position_y
      var x_px = $('#storycard-cropper').position().left +  $('#storycard-crop-image-container').scrollLeft();
      var y_px = $('#storycard-crop-image-container').scrollTop(); 
      var cropper_position_x = $('#storycard-cropper').position().left;
      
      
      //obtaining in %
      x = x_px / width_px; 
      y = y_px / height_px; 

      on_edit(illustration_id, page_id, {
	cropper_position_x: cropper_position_x,
	imgUrl: url,
	imgX1: x_px * ratio_x,
	imgY1: y_px * ratio_y,
	cropW: width_px * ratio_x,
	cropH: height_px * ratio_y,
	imgW: width * ratio_x,
	imgH: height * ratio_y,
	imgInitW: image_geometry.width,
	imgInitH: image_geometry.height,
	scale: scale,
	story_card_cropper: true
      });
    });
  }

  var init_publish_link = function(on_publish, publish){
    story_page_validation_errors_dialog.dialog({
      autoOpen: false,
      width: 600,
      modal: true,
      buttons : {
        "Ok" : function() {
          $(this).dialog("close");
        }
      },      
      dialogClass: 'change_orientation_dialog'
    });
    story_page_validation_textbox_warnings.dialog({
      autoOpen: false,
      width: 450,
      modal: true,
      dialogClass: "textbox_warnings_dialog",
      buttons: {
        "Yes": function(){
      	  $(this).dialog('close');
      	  publish(story_id());
      	},
      	'Cancel': function(){
          $(this).dialog('close');
        }
      }
    });
    $("#publish").click(function () {
      on_publish(story_id());
    });
  };

  var init_edit_book_info = function(on_edit_book){
    $("#edit_book").click(function () {
      on_edit_book(story_id());
    });
  };

    var display_story_page_validation_errors = function(image_errors, orientation_errors, textbox_errors){
    // display image errors, don't allow user to publish
    if(image_errors.length != 0) {
        if(image_errors[0] == 1){
          if(image_errors[0] == 1 && image_errors.length == 1){
            story_page_validation_image_errors.html("Looks like you missed choosing an image for the front cover! Please go back and insert an image.");
          }else{
            story_page_validation_image_errors.html(
            'Looks like you missed choosing images for the front cover and ' + (image_errors.length == 2 ? 'page' : 'pages')+'('+image_errors.filter(function(page){return page == 1 ? "" : page }).join(', ') + ')! Please go back and insert images.'
            );
          }
        }
        else{
          story_page_validation_image_errors.html(
          'Looks like you missed choosing images for ' + (image_errors.length == 1 ? 'page' : 'pages')+'('+image_errors.map(function(page){return page}).join(', ') + ')! Please go back and insert images, or choose a layout that has only text.'
          );
        }
	story_page_validation_errors_dialog.dialog("open");
	return
    } 

    if(orientation_errors.length != 0) {
      story_page_validation_orientation_errors.html(
          'Page(s) ' + orientation_errors.map(function(page){return page == 1? 'Cover' : page}).join(', ') + ' has wrong orientation.'
      );
      story_page_validation_errors_dialog.dialog("open");
      return
    }

    // empty text boxes found, confirm user want to keep empty textboxes before publish
    if (textbox_errors !== "") {
      story_page_validation_textbox_warnings.html(textbox_errors.replace(/&quot;+/g, ''));
      story_page_validation_textbox_warnings.dialog('open');
    }
  };

  var update_authors_on_preview = function(){
    var authors = [];
    $(".fields[style!='display: none;']").each(function(i, form){
      var first_name = $(form).find('.story_authors_first_name input').val();
      var last_name = $(form).find('.story_authors_last_name input').val();
      authors.push((first_name + ' ' + last_name).trim());
    });
    if(is_derivation()){
      authors_preview_text = $('#review_book_covers').find('.derivation_authors');
    }
    authors_preview_text.text(authors.join(', '));
  };

  var changeLogo = function(logo_path){
    publisher_logo.attr('src', logo_path);
  }

  var updateLevelBand = function(url){
    reading_level_preview_text.attr('src', url);
  }

  var init_cover_page_preview_updates = function(){
    $('#story_title').blur(function(){
      title_preview_text.text($(this).val());
      back_cover_title_preview_text.text($(this).val());
    }).blur();
    $('#story_synopsis').blur(function(){
      synopsis_preview_text.text($(this).val());
    }).blur();
    $('.story_reading_level').change(function(){
      rdLevel = $('.story_reading_level .radio input:checked')[0].value
      $.ajax({
        url : '/v0/story/level_band',
        type: "GET",
        data : {story_id: story_id, reading_level: rdLevel},
        contentType: false,
        dataType : 'json',
        success: function(data){
          updateLevelBand(data["url"]);
        }
      });
      back_cover_reading_level_preview_text.text(reading_level_help(rdLevel));
    }).change();
    $('#story_organization_id').change(function(){
      var elem = $(this)[0];
      var pub_id = elem[elem.selectedIndex].value;
     $.ajax({
        url : '/v0/profile/pub_logo',
        type: "GET",
        data : {organization_id: pub_id},
        contentType: false,
        dataType : 'json',
        success: function(data){
          changeLogo(data["logo_path"]);
        }
      });
    }).change();
    author_form_fields
      .find(author_first_name_selector)
      .on('input', function() {
        update_authors_on_preview();
      });
    author_form_fields
      .find(author_last_name_selector)
      .on('input', function() {
        update_authors_on_preview();
      });
    $(document).on('nested:fieldAdded', function(event){
      event.field.find(author_first_name_selector)
      .on('input', function() {
        update_authors_on_preview();
      });
      event.field.find(author_last_name_selector)
        .on('input', function() {
          update_authors_on_preview();
        });
    });
    $(document).on('nested:fieldRemoved', function(event){
      update_authors_on_preview();
    });
  };


  var init_publish_story_form = function(on_publish){
    init_cover_page_preview_updates();
    $('#story_category_ids').multiselect({
      buttonWidth : '100%'
    });
    publish_form.ajaxForm({
      dataType:  'script',
      beforeSubmit: function(){$.blockUI()},
      success: function(){$.unblockUI()},
      error: function(e){
        $.unblockUI();
        alert('There was an error while processing your action, please retry after some time.');
      }
    });
    $("#publish_story").click(function(){
      submit_publish_form(true);
    });
    $("#save_and_close, #save_and_close_form1, #save_and_close_form2").click(function(){
      submit_publish_form(false);
    });

    $("#save_book_info").click(function(){
       submit_book_info_form(false);
    });

  };

  var submit_publish_form = function(is_publish){
    stort_id = story_id();
    javascript:window.onbeforeunload = null;
    form_url = is_publish ? "/v0/editor/story/"+stort_id+"/publish" : "/v0/editor/story/"+stort_id+"/update"
    $.ajax({
        url : form_url,
        type: "POST",
        data : $("#publish_form").serialize(),
        dataType : 'script',
        success:function(data, textStatus, jqXHR){}
    });
  };

  var submit_book_info_form = function(is_publish){
        stort_id = story_id();
        javascript:window.onbeforeunload = null;
        form_url = "/v0/editor/story/"+stort_id+"/update_book_info";
        $.ajax({
            url : form_url,
            type: "POST",
            data : $("#book_edit_from").serialize(),
            dataType : 'script',
            success:function(data, textStatus, jqXHR){}
        });
    };

  var init_original_text = function(){
    $("#original-text-container").draggable({
      containment: ".container-fluid",
      cancel: '.text',
      scroll: false
    });
    $('.original_text').resizable({
      "minHeight": 128,
      "minWidth": 480
    });
  };

  var reading_level_help = function(level){
    return $('#reading_level_help').data('level'+ level +'Help');
  };

  var init_cannot_edit_front_cover_dialog = function(){
    cannot_edit_front_cover_dialog.dialog({
      autoOpen: false,
      width: 600,
      modal: true,
      buttons : {
      	"Ok" : function() {
        $(this).dialog("close");
      	}
      },
      dialogClass: 'change_orientation_dialog'
    });
    front_cover_title.click(function (evt) {
     	evt.preventDefault();
        cannot_edit_front_cover_dialog.dialog("open");
    });
  };

  var previous_page_click = function(){
    previous_page_link.click(function(){
        if ($('div.active.page').hasClass("BackCoverPage")) {
            $('div.active.page').parent().prev().children().last().children('a.page_thumbnail').trigger("click")
        }else if ($('div.active.page').parent().children().first().hasClass("active")) {
            $('div.active.page').parent().prev().children().last().children('a.page_thumbnail').trigger("click")
        }
        else {
            $('div.active.page').prev().children('a.page_thumbnail').trigger("click")
        }

    })
  };

  var next_page_click = function(){
      next_page_link.click(function(){
        if ($('div.active.page').hasClass("FrontCoverPage")) {
            $('div.active.page').parent().next().children().first().children('a.page_thumbnail').trigger("click")
        }else if ($('div.active.page').parent().children().last().hasClass("active")) {
            $('div.active.page').parent().next().children().last().children('a.page_thumbnail').trigger("click")
        }
        else {$('div.active.page').next().children('a.page_thumbnail').trigger("click")}

    })
  };

  page_controll_links_visibility = function() {
    if (is_derivation()){
      document.getElementById('add_page').style.pointerEvents = 'none';
      if (document.getElementById('change_image') != null)
        document.getElementById('change_image').style.pointerEvents = 'none';
      if (document.getElementById('delete_image') != null)
        document.getElementById('delete_image').style.pointerEvents = 'none';
      document.getElementById('toolbar').style.pointerEvents = 'auto'
    }else{document.getElementById('add_page').style.pointerEvents = 'auto';
        document.getElementById('toolbar').style.pointerEvents = 'auto';
    }
    if ($('div.active.page').hasClass("FrontCoverPage")) {
      previous_page_link.addClass('disabled');
      document.getElementById('add_page').style.pointerEvents = 'none';
      document.getElementById('previous_page').style.pointerEvents = 'none';
      document.getElementById('toolbar').style.pointerEvents = 'none';
    }else {previous_page_link.removeClass('disabled')}
    if ($('div.active.page').hasClass("BackCoverPage")) {
      document.getElementById('add_page').style.pointerEvents = 'none';
      document.getElementById('next_page').style.pointerEvents = 'none';
      document.getElementById('toolbar').style.pointerEvents = 'none';
      next_page_link.addClass('disabled');
    }else {next_page_link.removeClass('disabled')}

  };

  return {
    page_id: page_id,
      story_id: story_id,
      contents: contents,
      update_last_saved_time: update_last_saved_time,
      //illustrations_click: illustrations_click,
      templates_click: templates_click,
      insert_page_click: insert_page_click,
      delete_page_click: delete_page_click,
      duplicate_page_click: duplicate_page_click,
      rearrange: rearrange,
      click: click,
      disable_page_manipulation_links: disable_page_manipulation_links,
      enable_page_manipulation_links: enable_page_manipulation_links,
      enable_textbox_create_button: enable_textbox_create_button,
      init_publish_link: init_publish_link,
      display_story_page_validation_errors: display_story_page_validation_errors,
      init_publish_story_form: init_publish_story_form,
      is_derivation: is_derivation,
      enable_page_manipulation_links_for_derivation: enable_page_manipulation_links_for_derivation,
      init_original_text: init_original_text,
      set_pages_ribbon_width: set_pages_ribbon_width,
      is_page_template_is_full_text_vertical_template: is_page_template_is_full_text_vertical_template,
      is_page_template_is_full_text_horizontal_template: is_page_template_is_full_text_horizontal_template,
      init_cannot_edit_front_cover_dialog: init_cannot_edit_front_cover_dialog,
      previous_page_click: previous_page_click,
      next_page_click: next_page_click,
      page_controll_links_visibility: page_controll_links_visibility,
      add_page_click: add_page_click,
      init_edit_book_info: init_edit_book_info,
      textbox_id: textbox_id,
      click_editor: click_editor,
      destroy_textbox: destroy_textbox,
      textbox_resize_drag: textbox_resize_drag,
      getQuery: getQuery,
      background_color: background_color,
      set_textbox_border: set_textbox_border, 
      set_storycard_view: set_storycard_view 
  };
}
