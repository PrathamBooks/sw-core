Story = (function(){
  var storyCardTemplate;
  var loadMoreTemplate;
  var storyHolder;
  var loadStoriesURL;
  var perPage;
  var restrictPageLoad;
  var searchQueryTemplate;
  var queryHolder;
  var storyLikeButtonsIdentifier;
  var storyRecommandButtonsIdentifier;
  var storyCheckbox;
  var storyCheckboxSelectAll;
  var storyCheckboxDeselectAll;
  var flag = false;

  var sortOptions = {
        "published_at" : {published_at: { order: "desc"}},
        "reads" : { reads: { order: "desc"}},
        "likes" : { likes: { order: "desc"}},
        "recommendation" : { recommendation: { order: "desc"}},
        "ratings" : {ratings: {order: "desc"}}
       };

  var sortUsingFilter = function(obj,sort_by,desktop){
      if(desktop){
        obj.siblings('.active-tab').removeClass("active-tab");
        obj.addClass("active-tab");
      }else {
        $("#Recommended").removeClass("active-tab");
      }

      appliedFilters = getSearchFilters();
      appliedFilters.search["cache"] = true

      if(sort_by == "recommended"){
        appliedFilters.search.recommended = true
      }
      else{
        appliedFilters.search.sort = sortOptions[sort_by];
      }

      appliedFilters.per_page = perPage;
      removeAllCards();
      removeLoadMore();
      loadCards();
  };

  var initializeSortBy = function(){
    $("#NewArrivals").click(function(){
      sortUsingFilter($(this),"published_at",true);
    });

    $("#MostRead").click(function(){
      sortUsingFilter($(this),"reads",true);
    });

    $("#MostLiked").click(function(){
      sortUsingFilter($(this),"likes",true);
    });

    $("#Recommended").click(function(){
      sortUsingFilter($(this),"recommended",true);
    });

    $("#SortList").change(function(){
      sortUsingFilter($(this),$(this).val(),false);
    });
  };

  var getTemplate = function (id,intializeList){
    var block  = $(id);
    var source = block.html();
    block.remove();

    if(intializeList){
      Handlebars.registerHelper('list', function(items, options) {
        var out = "";

        for(var i=0, l=items.length; i<l; i++) {
          out = out + options.fn(items[i]);
        }
        return out;
      });
      Handlebars.registerHelper('comma_separated_list', function(items, options) {
        return items.join(', ');
      });
      Handlebars.registerHelper('comma_separated_url_list', function(authors, author_slugs, options) {
        var authors_list = []
        var url = "/users/"
        for (author=0; author < authors.length; author++){
          var anchor = "<a href="+url+author_slugs[author]+">"+authors[author]+"</a>"
          authors_list.push(anchor)
        };
        return authors_list.join(', ');
      });
      Handlebars.registerHelper('language_list', function(items, options) {
        var url = "/search?search[language]="
        var anchor = '<a href="'+url+items+'">'+items+'</a>'
        return anchor;
      });
      Handlebars.registerHelper('reading_level_list', function(items, options) {
        var url = "?search[reading_level]="
        var anchor = '<a href="'+url+items+'"> Level '+items+'</a>'
        return anchor;
      });
      Handlebars.registerHelper('publisher_list', function(publisher, publisher_slug, options) {
        var url = "/publishers/";
        var anchor = "<a href="+url+publisher_slug+">"+publisher+"</a>"
        return anchor;
      });
    }
     
    return Handlebars.compile(source);
  };
  
  var initializeStoryCard = function(){
    storyCardTemplate = getTemplate("#story_card",true);
    loadMoreTemplate = getTemplate("#load_more",false);
    searchQueryTemplate = getTemplate("#keyword_query",false);
  };

  var createLoadMore = function(){
    loadMoreHtml =  loadMoreTemplate();
    storyHolder.append(loadMoreHtml);
    initializeLoadMore();
    $("#DIV_STORY_FEED").masonry()
  };

  var createSearchQuery = function(count,query){
    removeSearchQuery();
    createBooksCount(count);
    var value = {
      count: count,
      query: query.trim()   
    }
    var searchQueryHtml = searchQueryTemplate(value);
    queryHolder.append(searchQueryHtml); 
  };
  var createBooksCount = function(count){
    $("#BooksCount").text(count+" Books");
  }
 
  var initializeCheckBox = function(){
    $(storyCheckboxSelectAll).click(function(){
      if($(storyCheckboxDeselectAll).is(':checked')){ 
        $(storyCheckboxDeselectAll).prop("checked",false)
      }
      check_for_select_all()
    });
    $(storyCheckboxDeselectAll).click(function(){
       $("#tiles_selected_text").html("")
        $(storyCheckboxSelectAll).prop("checked",false)
        $(storyCheckbox).prop("checked",false)
      
    })
    $(storyCheckbox).click(function(){
      $(storyCheckboxDeselectAll).prop("checked",false)
      if($(this).is(':checked')){
         if($('[name="select_to_download"]:checked').length <= 10){
              download_count_text();
              $(this).prop("checked",true)
              flag = false;
         }else if(flag == false){
           $(this).prop("checked",false)
            $("#download_limit_alert").dialog("open");
            flag = true;
         }else{
           $(this).prop("checked",false)
           $("#download_limit_alert").dialog("open");
         }
      }else{
        download_count_text();
        $(this).prop("checked",false)
      }
    });
  };
 
  var download_count_text = function(){
    return $("#tiles_selected_text").html($('[name="select_to_download"]:checked').length+" selected out of 10 for download");
  }

  var removeSearchQuery = function(){
    queryHolder.empty();
  };

  var initializeLoadMore = function(){
    storyHolder.find("#LoadMore").click(function(){
      $(this).remove();
      appliedFilters.page+=1;
      loadCards();
    });
  };

  var showRedirectLink = function(){
    storyHolder.find("#LoadMore").remove();
    $("#NavigateToSearchPage").removeClass('hide');
  };

  var alterSynopsis = function(value){
    options = [50,100,150,200,250,300];
    synopsis = value["synopsis"];
    value["show_more"] = false;
    max_length = options[Math.floor(Math.random() * options.length)];
    if(value["synopsis"])
      {
        value["synopsis"] = value["synopsis"].substring(0,max_length);
        if(value["synopsis"].length < synopsis.length)
          value["show_more"] = true;
      }
  };

 var check_for_select_all = function(){
   if($(storyCheckboxSelectAll).is(':checked')){ 
    $(storyCheckbox).each(function(){
     if($('[name="select_to_download"]:checked').length < 10){
      if(!$(this).hasClass("story_downloaded")){
        $(this).prop("checked",true)
        download_count_text();
        flag = false;
      }
     }else if(flag == false ){
      $("#download_limit_alert").dialog("open");
      flag = true;
      return false;
     }
    });
    }else{
      $(storyCheckbox).prop("checked",false)
      $("#tiles_selected_text").html("")
    };
  };

  var story_tile_checked = function(id){
    if($(storyCheckboxSelectAll).is(':checked')){
       if($('[name="select_to_download"]:checked').length < 10){
          if(!$("#story_tile_check_"+id).hasClass("story_downloaded")){  
            $("#story_tile_check_"+id).prop("checked",true)
            download_count_text();
            flag = false;
          }
       }else if(flag == false){
         download_count_text();
          $("#download_limit_alert").dialog("open");
          flag = true;
       }
    }
  };

  var create_cards = function(results) {
    if(restrictPageLoad)
      $("#NavigateToSearchPage").addClass('hide');
    var divFeed = storyHolder.find("#DIV_STORY_FEED");
      $.each(results, function(key, value) {
          cardId = "#STORY_DIV_"+value['id'];
          if( divFeed.find(cardId).length <= 0) {
            alterSynopsis(value);
            var cardHtml =  storyCardTemplate(value);
            divFeed.last().append(cardHtml);
            disbaleLikeActionInMobile(value['id']);          
            var boxes = divFeed.find(cardId);
            divFeed.masonry( 'appended', boxes, true);
            $("#story-rating-"+value['id']).rating()
            story_tile_checked(value['id'])
        }
      });
      divFeed.imagesLoaded( function() {
        divFeed.masonry("layout");
      });
  };

  var removeAllCards = function(){
    //window.scrollTo(0,0);
    var divFeed = storyHolder.find("#DIV_STORY_FEED");
    divFeed.empty();
    divFeed.masonry("layout");
    storyHolder.find("#NO_RESULTS").addClass('hide');
  };

  var createNoResults = function(){
    blankInfo = storyHolder.find("#NO_RESULTS");
    if(blankInfo.hasClass('hide')){
      blankInfo.removeClass('hide');
    }
  };

  var removeLoadMore = function(){
    storyHolder.find("#LoadMore").remove()
  };
  
  var hideSideBar = function(){
    if($('.slide-left-sidebar').css('display') != "none"){
      $(".left-sidebar").animate({width: 'toggle'}, "fast");
      $(".slide-left-sidebar").removeClass('tog-open');
    }
  };

  var updateStoriesCount = function(total){
    var storiesCount = $("#stories-count");
    storiesCount.text(total);
 
  };

  var DownloadStatus = function(modal_id){
    $(".download-link").click(function(){
      $("#downloadStartModal").modal('show');
      setTimeout(function(){
        $('#downloadStartModal').modal('hide')
      }, 5000);
      $(modal_id).hide();
    });
  }
   
  var loadCards = function(){
    jQuery.ajax({
      type: "GET",
      cashe : false,
      async: true,
      url: loadStoriesURL,
      data : appliedFilters,
      dataType : "json",
      success : function(data) {
        createSearchQuery(data["metadata"]["hits"],data["query"]["query"]);
        if (data["search_results"].length > 0 ){
          if(restrictPageLoad && data["metadata"]["page"] > 3)
            showRedirectLink();
          else
          {
            create_cards(data["search_results"]);
            if(data["metadata"]["page"] < data["metadata"]["total_pages"]) {
              createLoadMore();
            }
            initializeCheckBox()
            if($('[name="select_to_download"]:checked').length >= 1){
              download_count_text();
            }
            $(".download-modal").click(function(){
              DownloadStatus($(this).data('target'));
            });
            $(storyLikeButtonsIdentifier).click(function(){
              var storyId = $(this).data('storyId');
              Statistics.trackStoryLike(storyId);
              if($(this).attr('class').indexOf('liked')===-1){
                $(this).removeClass('btn likeable');
                $(this).addClass('liked');
                $('#story-likes-'+storyId).text(parseInt($('#story-likes-'+storyId).text())+1);
              }
            });
            $(storyRecommandButtonsIdentifier).off("click")
            $(storyRecommandButtonsIdentifier).click(function(){
              var storyId = $(this).data('storyId');
                status = true
              if($('#change_text-'+storyId).text() == "to Editor's picks"){
                $('#change_text-'+storyId).text('from Editor'+"'"+'s picks');
                status = false
              }else{
                $('#change_text-'+storyId).text('to Editor'+"'"+'s picks');
                status = true
              }
              trackStoryRecommend(storyId, status);
              $(this).find('i').toggleClass('glyphicon glyphicon-plus home_recommended_green').toggleClass('glyphicon glyphicon-minus home_recommended_red');
            })
          }
          $('[data-toggle="tooltip"]').tooltip()
          $(".js-read-btn").click(function(){$.blockUI();})
          translationSuggestionUrl(true)
        }
        else{
          createNoResults();
          translationSuggestionUrl(false)
        }
      }});
  };

  var translationSuggestionUrl = function(show){
    var linkId=$("#all_translations");
    if(typeof linkId === 'undefined' || linkId === null) {
      return;
    }
    if (show){if(linkId.hasClass('hide')){
      linkId.removeClass('hide');
    }}else{linkId.addClass("hide");}
  };

  var trackStoryRecommend = function(id, status){
    if(typeof id === 'undefined' || id === null) {
      return;
    }
    $.ajax({
      url: "/stories/recommend_story_on_home",
      type: 'POST',
      data: {story_id:id, recommend:status},
      dataType : "json",
      failure: function(result) {
        console.error('Unable to update story recommendation.');
      }
    });
  };

  var resetToDefault = function(){
    $('.category_check_box').prop('checked', false);
    $('.language_check_box').prop('checked', false);
    $('.publisher_check_box').prop('checked', false);
    $('.reading_level_check_box').prop('checked', false);
    $('.derivation_type_check_box').prop('checked',false);
    $('#all_categories').prop('checked', true);
    $('#all_languages').prop('checked', true);
    $('#all_publishers').prop('checked', true);
    $('#all_reading_levels').prop('checked', true);
    $('#all_derivation_types').prop('checked', true);
    $('#show_all_stories').prop('checked', true);
    $(".sort-full").find("input").prop('checked', false);
    $("#ClearSortRead").addClass("hide");
  };

  var submitDefaultForm = function(){
    loadCards();
  };

  var onloadEvents = function() {
    storyHolder.find('#DIV_STORY_FEED').masonry({
      // options
      columnWidth : 40 ,
      isAnimated: true
    });
    submitDefaultForm();
  };

  var getSearchQuery = function(){
    var query = $("#search_query").val();
    return query ? query : ""; 
  };

  var getCategories = function(){
    categories = []
    $("#StoryCategories").find("li input:checked").each(function () {
          categories.push($(this).val());
        });
    return categories;
  };

  var getBulkStoriesOption = function(){
    bulk_download_stories = []
    $("#BulkOptions").find("li input:checked").each(function () {
          bulk_download_stories.push($(this).val());
        });
    return bulk_download_stories;
  };

  var getReadingLevels = function(){
    var selected_reading_level=getParameterByName("search[reading_level]")
    $("#StoryLevels").find("li input:checkbox").each(function () {
      if($(this).val() == selected_reading_level){
      $(this).prop('checked', true); 
      $('#all_reading_levels').prop('checked', false); 
      }
    });
    reading_levels = []
    $("#StoryLevels").find("li input:checked").each(function () {
          reading_levels.push($(this).val());
        });
    return reading_levels;
  };

  var getDerivationType = function(){
    var selected_derivation_type=getParameterByName("search[derivation_type]")
    $("#Derivation_Type").find("li input:checkbox").each(function () {
      if($(this).val() == selected_derivation_type){
      $(this).prop('checked', true); 
      $('#all_derivation_types').prop('checked', false); 
      }
    });
    derivation_type = []
    $("#Derivation_Type").find("li input:checked").each(function () {
       derivation_type.push($(this).val());
    });
    return derivation_type;
  }
  
  var getLanguages = function(){
    var selected_language = getParameterByName("search[language]");
    $("#StoryLanguages").find("li input:checkbox").each(function () {
      if($(this).val() == selected_language){
      $(this).prop('checked', true); 
      $('#all_languages').prop('checked', false); 
      }
    });
    languages = []
    $("#StoryLanguages").find("li input:checked").each(function () {
      languages.push($(this).val());
    });
    if (document.getElementById("s_language") != null) {
      languages.push($("#s_language").val());
    }
    return languages;
  };

  var getTargetLanguages = function(){
    var selected_language = getParameterByName("search[target_language]");
    languages = []
    languages.push($("#t_language").val());
    return languages;
  };


  var getPublishers = function(){
    var selected_organization = getParameterByName("search[organization]")
    $("#StoryPublishers").find("li input:checkbox").each(function () {
      if($(this).val() == selected_organization){
      $(this).prop('checked', true); 
      $('#all_publishers').prop('checked', false); 
      }
    });
      organizations = []
      $("#StoryPublishers").find("li input:checked").each(function () {
        if ($(this).val() != "true"){
          organizations.push($(this).val());}
      });
      return organizations;
  };

  var getChildCreated = function(){
    if ($("#search_categories_child-created").is(":checked")){
      return true;
    }
  };
  
  var getSortOptions = function(){
    sort_by = $("#StorySortOptions").find('input[name="sort"]:checked').val();
    return sortOptions[sort_by];
  };

  var getSortByRecommended = function(){
    if(($("#StorySortOptions").find('input[name="sort"]:checked').val() == "recommended") || $('.active-tab').html()=="Recommended")
      sort_by = true
    return sort_by;
  };
  var getAuthors = function(){
   var query = getParameterByName("search[authors]")
    return query ? query : ""; 
  };

  var getParameterByName = function (name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
    results = regex.exec(location.search.replace(/%5B/, '[').replace(/%5D/, ']'));
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
  };

  var history_push = function(){
    history.pushState(null, document.title, loadStoriesURL+"?"+jQuery.param(appliedFilters));
  };

  var loadForm = function(){
    appliedFilters = getSearchFilters();
    appliedFilters.page = 1;
    appliedFilters.per_page = 9;
    window.scrollTo(0,0);
    removeAllCards();
    removeSearchQuery();
    removeLoadMore();
    hideSideBar();
    //history_push(); Need to uncomment after finalizing google translation campaign filters
    loadCards(); 
  };

  var getSearchFilters = function(){
    var data = {
      search: {
        query: getSearchQuery(),
        categories: getCategories(),
        languages: getLanguages(),
        target_languages: getTargetLanguages(),
        organizations: getPublishers(),
        child_created: getChildCreated(),
        reading_levels: getReadingLevels(),
        derivation_type: getDerivationType(),
        bulk_options: getBulkStoriesOption(),
        sort: getSortOptions(),
        //recommended: getSortByRecommended(),
        authors: getAuthors(),
      },
      page: 1,
      per_page: perPage
    };
    if(restrictPageLoad) { // home page default filter
      data.search.sort = {recommendation: {order: 'desc'}};
    }
    return data;

  };

  var disbaleLikeActionInMobile = function(id){
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
      $(".hide-in-mob-like-"+id).click(function (evt) {
        evt.preventDefault();
        var dialogElement = $("#hide_mobile_like.hide_mobile_dialog");
            dialogElement.dialog("open");
          return false;
       });
      }
  };

  var add_applied_filters_to_url = function(){
    var contest_id = $("a#all_translations").data("contestId");
    if (contest_id=="") {
      $("#all_translations").attr("href", "/translate_suggestions?" + jQuery.param(appliedFilters));
    }else{
      $("#all_translations").attr("href", "/translate_suggestions?contest_id=" +contest_id+"&"+ jQuery.param(appliedFilters));
    }
  };

  $.fn.serializeObject = function()
  {
   var o = {};
   var a = this.serializeArray();
   $.each(a, function() {
       if (o[this.name]) {
           if (!o[this.name].push) {
               o[this.name] = [o[this.name]];
           }
           o[this.name].push(this.value || '');
       } else {
           o[this.name] = this.value || '';
       }
   });
   return o;
  };

  return {
    initialize: function(storySearchPath,per_page,restrict_page_load,cache)
    {
      loadStoriesURL   = storySearchPath;
      perPage = per_page;
      restrictPageLoad = restrict_page_load;
      appliedFilters  = getSearchFilters();
      storyHolder = $("#story-holder");
      queryHolder = $("#query_holder");
      storyLikeButtonsIdentifier = ".story-like.likeable";
      storyRecommandButtonsIdentifier = ".story-type"
      storyCheckbox = ".check_story"
      storyCheckboxSelectAll = "#select_all"
      storyCheckboxDeselectAll = "#de_select_all"
      initializeStoryCard();
      initializeSortBy();
      appliedFilters.per_page = per_page;
      appliedFilters.search["cache"] = cache 
      window.onload = onloadEvents();
    },
    submitForm: function()
    {
      loadForm();
      history_push();
    },
  resetForm: function(){
    resetToDefault();
    loadForm();
    history_push();
  },
  translateSubmitForm: function(){
    loadForm();
    add_applied_filters_to_url()
  },
    removeLoadMore: function() {removeLoadMore()}
  };

})();
