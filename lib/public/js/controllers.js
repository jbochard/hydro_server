

ang.controller('HydroponicController', function($scope, $location, nurseriesService) {

  $scope.nursery_types = [{ name: "Cajón", type: "drawer"}, { name: "Almácigos", type: "nursery"}];
  $scope.template = '';

  $scope.range = function(max) {
    var range = [];
    for(var i = 0; i < max; i++) {
      range.push(i);
    }
    return range;
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

  $scope.add_nursery = function() {
    $scope.nursery = { name: "", type: "nursery", dimensions: { length: 1, width: 1 } }
    $scope.template = '/nursery-add.html'
  }

  $scope.save_nursery = function() {
    nurseriesService.post($scope.nursery, 
      function(result) {
        refreshNurseries($scope.queryNursery);
      },
      function(result) {
      });
  }

  $scope.remove_nursery = function(id) {
    nurseriesService.delete(id.$oid, 
      function(result) {
        refreshNurseries($scope.queryNursery);
      },
      function(result) {
      });
  }

  $scope.show_nursery = function(id) {
    nurseriesService.get(id.$oid, function(response) {
      $scope.nursery = response;
      $scope.template = '/nursery-show.html';
    }, 
    function(response) {
    });
  }
});