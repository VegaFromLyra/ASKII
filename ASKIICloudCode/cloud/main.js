
Parse.Cloud.afterSave("Question", function(request) {

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

  // var locationId = request.object.get("location").id;
  // var locQuery = new Parse.Query("Location");
  // locQuery.equalTo("objectId", locationId);

  // locQuery.first({
  //   success: function(location) {
  //     // Find users near a given location
  //     // var userLocQuery = new Parse.Query("UserLocation");
  //     // userLocQuery.withinMiles("lastKnownLocation", location.get("coordinate"), 1.0);

  //     // Find users near a given location
  //     var userQuery = new Parse.Query(Parse.User);
  //     userQuery.withinMiles("location", location.get("coordinate"), 1.0);

  //     // Find devices associated with these users
  //     var pushQuery = new Parse.Query(Parse.Installation);
  //     pushQuery.matchesQuery('user', userQuery);

  //     console.log("Created push query");

  //     // Send push notification to query
  //     Parse.Push.send({
  //         where: pushQuery,
  //         data: {
  //           alert: "Someone asked a question about your location!"
  //         }
  //       }, {
  //           success: function() {
  //             console.log("Push was successful");
  //           },
  //           error: function(error) {
  //             console.log(error);
  //           }
  //     });
  //   }, 
  //   error: function(location, error) {
  //     console.log(error);
  //   }
  // });
});