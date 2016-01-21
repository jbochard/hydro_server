

ang.controller('HydroponicController', function($scope, $location, nurseriesService) {

  $scope.template = '';

  $scope.range = function(max) {
    var range = [];
    for(var i = 0; i < max; i++) {
      range.push(i);
    }
    return range;
  }

  $scope.templateUrl = function() {
    return $scope.url;
  }
 
  function refreshNurseries(query) {
    nurseriesService.getAll(query, function(response) {
      $scope.nurseries = response.data;
    },
    function(response) {
    });     
  }

  refreshNurseries($scope.queryNursery);

  $scope.open_left = function() {
    snapper.open('left');    
  }

  $scope.show_nursery = function(id) {
    nurseriesService.get(id.$oid, function(response) {
      $scope.nursery = response;
      $scope.template = '/nursery.html';
    }, 
    function(response) {
    });
  }
});