$(function() {
  FB.init({
    appId   : App.appId,
    cookie  : true,
    oauth   : true
  });

  // If user is not logged in, we try to authenticate from Facebook.
  if (!App.userId) {
    
    // Query Facebook API for authentication data
    FB.getLoginStatus(function(response) {
      
      // The user already connected to the app, so we just need to 
      // send the access token to login the user.
      if (response.status === 'connected') {
        $('#access-token').val(response.authResponse.accessToken);
        $('#auth-form').submit();
      }
      else {
        // The user hasn't connected yet, so we redirect to the 
        // Facebook Authentication Dialog.
        window.location = App.authUrl;
      }
    });
  }
});