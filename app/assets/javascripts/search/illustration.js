Illustration = (function(){
  var illustrationCardTemplate;
  var loadMoreTemplate;
  var illustrationHolder;
  var loadIllustrationsURL;
  var perPage;
  var restrictPageLoad;
  var queryHolder;
  var searchQueryTemplate;
  var illustrationLikeButtonsIdentifier;
  var contestId;
  var addIllustrationToContest;

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

      Handlebars.registerHelper('comma_separated_url_illustrator_list', function(illustrators, illustrator_slugs, options) {

        var illustrators_list = []
        var url = "/users/"
        for (illustrator=0; illustrator < illustrators.length; illustrator++){
          var anchor = "<a href="+url+illustrator_slugs[illustrator]+">"+illustrators[illustrator]+"</a>"
          illustrators_list.push(anchor)
        };
        
        return illustrators_list.join(', ');
      });
    } 
    
    return Handlebars.compile(source);
  };

  var initializeIllustrationCard = function(){
    illustrationCardTemplate = getTemplate("#illustration_card",true);
    loadMoreTemplate = getTemplate("#load_more",false);
    searchQueryTemplate = getTemplate("#keyword_query",false);
  };

  var createLoadMore = function(){
    loadMoreHtml =  loadMoreTemplate();
    illustrationHolder.append(loadMoreHtml);
    initializeLoadMore();
    $("#DIV_ILLUSTRATION_FEED").masonry()
  };

  var createSearchQuery = function(count,query){
    removeSearchQuery();
    var value = {
      count: count,
      query: query.trim()   
    }
    var searchQueryHtml = searchQueryTemplate(value);
    queryHolder.append(searchQueryHtml); 
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
            disbaleCreateActionInMobile(value['id']);
            disbaleLikeActionInMobile(value['id']);          
            var boxes = divFeed.find(cardId);
            divFeed.masonry( 'appended', boxes, true);
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
            $(illustrationLikeButtonsIdentifier).click(function(){
              var illustrationId = $(this).data('illustrationId');
              Statistics.trackIllustrationLike(illustrationId);
              if($(this).attr('class').indexOf('liked')===-1){
                $(this).removeClass('btn likeable');
                $(this).addClass('liked');
                $('#illustration-likes-'+illustrationId).text(parseInt($('#illustration-likes-'+illustrationId).text())+1);
              }
            });
            $(addIllustrationToContest).click(function(){
              var contest_url = [];
              contest_url = window.location.search.substring(1).split("=");
              var illustrationId = $(this).data('illustrationId');
               var contest_id = $(this).data('contestId');
              if($('#change_text-'+illustrationId).text() == "To"){
                $('#change_text-'+illustrationId).text("From ") 
              }else{
                $('#change_text-'+illustrationId).text("To") 
              }
              trackIllustrationContest(illustrationId, contest_id, contest_url[0]);
              $(this).find('i').toggleClass('glyphicon glyphicon-plus home_recommended_green').toggleClass('glyphicon glyphicon-minus home_recommended_red');
            })
        }
        else{
          createNoResults(); 
        }
      }});
  };

  var trackIllustrationContest = function(id, contest_id, contest_url){
    if(typeof id === 'undefined' || id === null) {
      return;
    }
    $.ajax({
      url: "/illustrations/contest_image",
      type: 'POST',
      data: {illustration_id:id, contest_id:contest_id},
      dataType : "json",
      failure: function(result) {
        console.error('Unable to update contest illustration.');
      },
      success : function(data) {
        if(contest_url != "contest_id"){
          window.location.reload();
        }
      }

    });
  };

  var submitDefaultForm = function(){
    loadCards();
  };

  var onloadEvents = function() {
    illustrationHolder.find('#DIV_ILLUSTRATION_FEED').masonry({
      // options
      columnWidth : 40 ,
      isAnimated: true
    });
    submitDefaultForm();

  };
 
  var sortOptions = {
        "updated_at" : {updated_at: { order: "desc"}},
        "reads" : { reads: { order: "desc"}},
        "likes" : { likes: { order: "desc"}}
       };


  var getSortOptions = function(){
    sort_by = $("#StorySortOptions").find('input[name="sort"]:checked').val();
    return sortOptions[sort_by];
  };


  var getSearchQuery = function(){
    var query = $("#search_query").val();
    return query ? query : ""; 
  };
  
  var getCategories = function(){
    categories = []
    $("#IllustrationCategories").find("li input:checked").each(function () {
          categories.push($(this).val());
        });
    return $.unique(categories);
  };

  var getPublishers = function(){
    var selected_organization = getParameterByName("search[organization]")
    $("#IllustrationPublishers").find("li input:checkbox").each(function () {
      if($(this).val() == selected_organization){
      $(this).prop('checked', true); 
      $('#all_publishers').prop('checked', false); 
      }
    });
      organization = []
      $("#IllustrationPublishers").find("li input:checked").each(function () {
        if ($(this).val() != "true"){
          organization.push($(this).val());}
      });
      return organization;
  };

  var getChildCreated = function(){
    if ($("#search_categories_child-created").is(":checked")){
      return true;
    }
  };

  var getStyles = function(){
    styles = []
    $("#IllustrationStyles").find("li input:checked").each(function () {
          styles.push($(this).val());
        });
    return $.unique(styles);
  };

  var getLicenseTypes = function(){
    licenses = []
    $("#IllustrationLicenseTypes").find("li input:checked").each(function () {
          licenses.push($(this).val());
        });
    return $.unique(licenses);
  };

  var getIllustrators = function(){
   var query = getParameterByName("search[illustrators]")
    return query ? query : ""; 
  };

  var getParameterByName = function (name) {
    name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
    results = regex.exec(location.search.replace(/%5B/, '[').replace(/%5D/, ']'));
    return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
  };

 var resetToDefault = function(){
    $('.publisher_check_box').prop('checked', false);
    $('.category_check_box').prop('checked', false);
    $('.style_check_box').prop('checked', false);
    $('.license_type_check_box').prop('checked', false);
    $('#all_categories').prop('checked', true);
    $('#all_styles').prop('checked', true);
    $('#all_publishers').prop('checked', true);
    $('#all_license_types').prop('checked', true);
    $(".sort-full").find("input").prop('checked', false);
    $("#ClearSort").addClass("hide");
  };

  var getSearchFilters = function(){

    var data = {
      search: {
        query: getSearchQuery(),
        categories: getCategories(),
        styles: getStyles(), 
        organization: getPublishers(),
        child_created: getChildCreated(),
        license_types: getLicenseTypes(),
        contest_id:contestId,
        illustrators: getIllustrators(),
        sort: getSortOptions(),
        image_mode: false
      },
      page: 1,
      per_page: perPage
    }
    return data;
  };

  var loadForm = function(){
    appliedFilters = getSearchFilters();;
    appliedFilters.page = 1;
    appliedFilters.per_page = 9;
    window.scrollTo(0,0);
    removeAllCards();
    removeSearchQuery();
    removeLoadMore();
    loadCards();
  }

  var disbaleLikeActionInMobile = function(id){
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
      $("#illustration-like-"+id).click(function (evt) {
        evt.preventDefault();
        var dialogElement = $("#hide_mobile_like.hide_mobile_like_dialog");
            dialogElement.dialog("open");
          return false;
       });
      }
  };

  var disbaleCreateActionInMobile = function(id){
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
      $(".hide-in-mob-create_"+id).click(function (evt) {
        evt.preventDefault();
        var dialogElement = $("#hide_mobile_create.hide_mobile_dialog");
            dialogElement.dialog("open");
          return false;
       });
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
    initialize: function(illustrationSearchPath,per_page)
    {
      loadIllustrationsURL   = illustrationSearchPath;
      appliedFilters  = getSearchFilters();
      perPage = per_page;
      illustrationHolder = $("#illustration-holder");
      queryHolder = $("#query_holder");
      illustrationLikeButtonsIdentifier = ".illustration-like.likeable";
      addIllustrationToContest = ".contest-image"
      initializeIllustrationCard();
      appliedFilters.per_page = per_page;
      window.onload = onloadEvents();
    },
    submitForm: function()
    {
      loadForm();
    },
    resetForm: function(){
      resetToDefault();
      loadForm();
    },
    contest: function(illustrationSearchPath,per_page,contest_id){
        loadIllustrationsURL   = illustrationSearchPath;
        contestId = contest_id
        appliedFilters  = getSearchFilters();
        perPage = per_page;
        illustrationHolder = $("#illustration-holder");
        queryHolder = $("#query_holder");
        illustrationLikeButtonsIdentifier = ".illustration-like.likeable";
        addIllustrationToContest = ".contest-image"
        initializeIllustrationCard();
        appliedFilters.per_page = per_page;
        window.onload = onloadEvents();
    }

  };

})();
