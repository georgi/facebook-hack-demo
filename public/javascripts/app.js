$(function() {
  FB.init({
    appId   : Config.appId,
    cookie  : true,
    oauth   : true
  });

  FB.getLoginStatus(function(response) {
    if (response.status === 'connected') {
      console.log("HELLO")
    } else {
      window.location = Config.authUrl
    }
  });
});