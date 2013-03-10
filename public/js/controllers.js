function StopListCtrl($scope, $routeParams, socketio, $http) {
  $http.get('stop_data').success( function(data) {
    $scope.stops = data;
    $scope.stop_names = _.map(Object.keys(data), function(stop_id) {
      return {stop_name: data[stop_id]['stop_name'],
        stop_id: stop_id
        };
    });
  });

  socketio.on('bus data', function(data) {
    console.log('got stop data');
    $scope.stops = data.stops;
    console.log($scope.stops);
  });

  $scope.selectStop = function(stop) {
    $scope.selected_id = $routeParams.stopId;
  }
}
function StopDetailCtrl($scope, $routeParams, $http) {
  $http.get('stop_data').success( function(data) {
    $scope.stops = data;
  });
  $scope.selected_id = $routeParams.stopId;
}
