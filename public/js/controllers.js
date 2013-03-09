function StopListCtrl($scope, $routeParams, socketio) {
  $scope.stops = [];
  socketio.on('bus data', function(data) {
    console.log('got stop data');
    $scope.stops = data.stops;
  });

  $scope.selectStop = function(stop) {
    console.log(stop);
    $scope.selected_stop = stop;
  }
}
function StopDetailCtrl($scope, $routeParams) {
  $scope.stopId = $routeParams.stopId;
}
