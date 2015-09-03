
Parse.Cloud.afterSave("Question", function(request) {

  // TODO: This is just a test implementation to verify push
  // notifications work. Need to set up advanced targeting
  Parse.Push.send({
    channels: [ "Questions" ],
    data: {
      alert: "Someone asked a question about your location"
    }
  }, {
    success: function() {
      console.log("Push was successful");
    },
    error: function(error) {
      console.error(error);
    }
  });
});