angular.module('bus', ['busServices']).
  config(['$routeProvider', function($routeProvider) {
  $routeProvider.
  //when('/buses', {templateUrl: 'partials/stop-list.html',   controller: StopListCtrl}).
  when('/stops/:stopId', {templateUrl: 'partials/stop-detail.html', controller: StopDetailCtrl}).
  otherwise({redirectTo:'/'});
}]);
