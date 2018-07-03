Statistics = (function (){
  var trackStoryRead = function(id, auth_token){
    if(typeof id === 'undefined' || id === null) {
      return;
    }
    var key = [auth_token, id].join('-');
    $.ajax({
      url: "/v0/statistics",
      type: 'PUT',
      data: {c:'Story',n:id, a:'Reads'},
      failure: function(result) {
        console.error('Unable to update story read statistics.');
      }
    });
  };

  var trackIllustrationRead = function(id, auth_token){
    if(typeof id === 'undefined' || id === null) {
      return;
    }
    var key = [auth_token, id].join('-');
    $.ajax({
      url: "/v0/statistics",
      type: 'PUT',
      data: {c:'Illustration',n:id, a:'Reads'},
      failure: function(result) {
        console.error('Unable to update illustration read statistics.');
      }
    });
  };

  var trackStoryLike = function(id, auth_token){
    if(typeof id === 'undefined' || id === null) {
      return;
    }
    var key = [auth_token, id].join('-');
    $.ajax({
      url: "/v0/statistics",
      type: 'PUT',
      data: {c:'Story',n:id, a:'Likes'},
      failure: function(result) {
        console.error('Unable to update story like statistics.');
      }
    });
  };

  var trackIllustrationLike = function(id, auth_token){
    if(typeof id === 'undefined' || id === null) {
      return;
    }
    var key = [auth_token, id].join('-');
    $.ajax({
      url: "/v0/statistics",
      type: 'PUT',
      data: {c:'Illustration',n:id, a:'Likes'},
      failure: function(result) {
        console.error('Unable to update illustration like statistics.');
      }
    });
  };

  var trackPopupViewed = function(){
    $.ajax({
      url: "/v0/statistics",
      type: 'PUT',
      data: {c:'Popup'},
      failure: function(result) {
        console.error('Unable to set popup session.');
      }
    });
  };


  return {
    trackStoryRead: trackStoryRead,
    trackIllustrationRead: trackIllustrationRead,
    trackStoryLike: trackStoryLike,
    trackIllustrationLike: trackIllustrationLike,
    trackPopupViewed: trackPopupViewed
  };
})();
