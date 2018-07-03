function IllustrationDrawerService(){
  var illustrationCardTemplate;
  var loadMoreTemplate;
  var illustrationHolder;
  var loadIllustrationsURL;
  var perPage;
  var queryHolder;
  var contestId;
  var favorites_of_story;
  var editor_fav_images;

  var getTemplate = function (id,intializeList){
    var block  = $(id);
    var source = block.html();
    // block.remove();

    if(intializeList) {
      Handlebars.registerHelper('list', function(items, options) {
        var out = "";

        for(var i=0, l=items.length; i<l; i++) {
          out = out + options.fn(items[i]);
        }

        return out;
      });
    }

    return Handlebars.compile(source);
  };

    var update_page_illustration = function(page_id, illustration_id){
        $.ajax({
          type: 'POST',
          url: '/v0/editor/page/'+ page_id +'/illustration/?page[illustration_id]='+ illustration_id,
          beforeSend: $.blockUI,
          success: $.unblockUI,
          error: function(e){
            $.unblockUI();
            alert('There was an error while processing your action, please retry after some time.');
          },
          dataType: 'script'
        });
     };

  var initializeIllustrationCard = function(){
    illustrationCardTemplate = getTemplate("#illustration_card",true);
    loadMoreTemplate = getTemplate("#load_more",false);
  };

  var createLoadMore = function(){
    illustrationHolder.find("#LoadMore").remove();
    loadMoreHtml = loadMoreTemplate();
    illustrationHolder.append(loadMoreHtml);
    initializeLoadMore();
    $("#DIV_ILLUSTRATION_FEED").masonry()
  };

  var createSearchQuery = function(count,query){
    var value = {
      count: count,
      query: query.trim()
    }
  };

  var removeSearchQuery = function(){
    queryHolder.empty();
  };

  var initializeLoadMore = function(){
    illustrationHolder.find("#LoadMore").click(function(){
      $(this).remove();
      appliedFilters.page+=1;
      loadCards();
    });
  };

  var create_cards = function(results) {
    var divFeed = illustrationHolder.find("#DIV_ILLUSTRATION_FEED");

      $.each(results, function(key, value) {
          cardId = "#ILLUSTRATION_DIV_"+value['id'];
          if( divFeed.find(cardId).length <= 0) {
            var cardHtml =  illustrationCardTemplate(value);
            divFeed.last().append(cardHtml);
            var boxes = divFeed.find(cardId);
            divFeed.masonry( 'appended', boxes, true);
            init_illustration_drawer("#illustration_"+value['id']);
        }
      });
      divFeed.imagesLoaded( function() {
        divFeed.masonry("layout");
      });
  };

  var removeAllCards = function(){
    var divFeed = illustrationHolder.find("#DIV_ILLUSTRATION_FEED");
    divFeed.empty();
    divFeed.masonry("layout");
    illustrationHolder.find("#NO_RESULTS").addClass('hide');
  };

  var createNoResults = function(){
    blankInfo = illustrationHolder.find("#NO_RESULTS");
    if(blankInfo.hasClass('hide')){
      blankInfo.removeClass('hide');
    }
  };

  var page_id = function(){
    return $('.page.active a').data('page-id');
  };

  var story_id = function(){
    return $('.page.active a').data('story-id');
  };

  var init_illustration_drawer = function(id){
      $(id).click(function(){
          $("#modal-image-drawer").modal("hide")
          update_page_illustration(page_id(), $(this).data('illustrationId'));

    });
  };

  var removeLoadMore = function(){
    illustrationHolder.find("#LoadMore").remove()
  };
  
  var updateIllustrationsCount = function(total){
    var illustrationsCount = $("#illusrtations_count");
    illustrationsCount.text(total);
  };
   
  var loadCards = function(){
    jQuery.ajax({
      type: "GET",
      cashe : false,
      async: true,
      url: loadIllustrationsURL,
      data : appliedFilters,
      dataType : "json",
      success : function(data) { 
        createSearchQuery(data["metadata"]["hits"],data["query"]["query"]);
        if (data["search_results"].length > 0 ){
            create_cards(data["search_results"]);
            if(data["metadata"]["page"] < data["metadata"]["total_pages"]){
              createLoadMore();
            }

            $(".update_fav").click(function(){
                var illustrationId = $(this).data('illustrationId');
                var active_tab = $("ul.nav-tabs-image-drawer li.active").text();
                if (active_tab == "favourites"){
                  $("#DIV_ILLUSTRATION_FEED").masonry( 'remove', $("#ILLUSTRATION_DIV_"+illustrationId) ).masonry();
                }else {
                  if($("#fav-illustration-"+illustrationId).text() == "save to favourites"){
                    $("#fav-illustration-"+illustrationId).text("remove from favourites")
                  }else{
                    $("#fav-illustration-"+illustrationId).text("save to favourites")
                  }
                }
                trackIllustrationFavorites(illustrationId, story_id());
            })
        }
        else{
          createNoResults(); 
        }
      }});
  };

    var trackIllustrationFavorites = function(ill_id, story_id){
        if(typeof ill_id === 'undefined' || ill_id === null) {
            return;
        }
        $.ajax({
            url: "/v0/illustrations/update_favorites",
            type: 'POST',
            data: {illustration_id:ill_id, story_id:story_id},
            dataType : "script",
            failure: function(result) {
                console.error('Unable to update favorite illustration.');
            }
        });
    };


    var submitDefaultForm = function(){
    loadCards();
  };

  var onloadEvents = function() {
    illustrationHolder.find('#DIV_ILLUSTRATION_FEED').masonry({
      // options
      columnWidth : 10 ,
      isAnimated: false
    });
    submitDefaultForm();

  };

  var submitIllustrationForm = function(){
      appliedFilters = getSearchFilters();;
      appliedFilters.page = 1;
      appliedFilters.per_page = 18;
      removeAllCards();
      removeSearchQuery();
      removeLoadMore();
      loadCards();
  };

  var getSearchQuery = function(){
    var query = $("#ill_search_query").val();
    return query ? query : ""; 
  };
  
  $('#search_query').keypress(function (e) {
      if (e.which == 13) {
        submitIllustrationForm();
      }
  });
  
  var getCategories = function(){
    categories = [];
    $("#collapseOne").find("div input:checked").each(function () {
          categories.push($(this).val());
        });
    return $.unique(categories);
  };

  var getStyles = function(){
    styles = [];
    $("#collapseTwo").find("div input:checked").each(function () {
          styles.push($(this).val());
        });
    return $.unique(styles);
  };

  var getPublishers = function(){
    publishers = [];
    $("#collapseThree").find("div input:checked").each(function () {
      publishers.push($(this).val());
    });
    return $.unique(publishers);
  };

  var sortOptions = {
    "updated_at" : {updated_at: { order: "desc"}},
    "reads" : { reads: { order: "desc"}},
    "likes" : { likes: { order: "desc"}}
  };


  var getSortOptions = function(){
    sort_by = $("#StorySortOptions").find(':checked').val();
    return sortOptions[sort_by];
  };

  var getSearchFilters = function(){

    var data = {
      search: {
        query: getSearchQuery(),
        categories: getCategories(),
        styles: getStyles(),
        organization: getPublishers(),
        sort: getSortOptions(),
        contest_id: contestId,
        image_mode: false
      },
      page: 1,
      per_page: perPage,
      story_id: story_id()
    }
    return data;
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
    initialize: function(illustrationSearchPath,per_page, editor_fav_images, favorites_of_story)
    {
      loadIllustrationsURL = illustrationSearchPath;
      appliedFilters  = getSearchFilters();
      perPage = per_page;
      appliedFilters.editor_fav_images = editor_fav_images;
      appliedFilters.favorites_of_story = favorites_of_story;
      illustrationHolder = $("#illustration-holder");
      queryHolder = $("#query_holder");
      initializeIllustrationCard();
      appliedFilters.per_page = per_page;
      removeAllCards();
      onloadEvents();
    },
    submitForm: function()
    {
      submitIllustrationForm();
    },

    contest: function(illustrationSearchPath,per_page,contest_id)
    {
      loadIllustrationsURL   = illustrationSearchPath;
      contestId = contest_id;
      appliedFilters  = getSearchFilters();
      perPage = per_page;
      illustrationHolder = $("#illustration-holder");
      queryHolder = $("#query_holder");
      initializeIllustrationCard();
      appliedFilters.per_page = per_page;
      onloadEvents();
    },
  };

}
