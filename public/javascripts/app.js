$(function() {
  FB.init({
    appId   : App.appId,
    cookie  : true,
    oauth   : true
  });

  if (!App.userId) {
    FB.getLoginStatus(function(response) {
      if (response.status === 'connected') {
        $('#access-token').val(response.authResponse.accessToken);
        $('#auth-form').submit();
      }
      else {
        window.location = App.authUrl;
      }
    });
  }
});