

ang.controller('HydroponicController', function($scope, $location, nurseriesService, plantsService, plant_typesService) {

  $scope.template = '';
  $scope.nurseries = [];
  $scope.plants = [];

  $scope.nursery_types = [{ name: "Cajón", type: "drawer"}, { name: "Almácigos", type: "nursery"}];
  $scope.new_nursery = {};

  $scope.sel_nursery = {};
  $scope.sel_bucket_pos = null;
  $scope.sel_nursery_taken_buckets = [];

  $scope.plant = { type: "" };
  $scope.plant_types = {}; 

  $scope.open_left = function() {
    snapper.open('left');    
  }

  $scope.range = function(max) {
    var range = [];
    for(var i = 0; i < max; i++) {
      range.push(i);
    }
    return range;
  }

  $scope.calculate_idx = function(r, c) {
    return Number(r * $scope.sel_nursery.dimensions.length + c + 1);
  }

  $scope.is_bucket_taken = function(r, c) {
    return $scope.sel_nursery_taken_buckets.contains($scope.calculate_idx(r, c));
  }

  $scope.select_bucket = function(r, c) {
    $scope.sel_bucket_pos = $scope.calculate_idx(r,c);
  }

  function refreshNurseries(query) {
    nurseriesService.getAll(query, function(response) {
      $scope.nurseries = response.data;
    },
    function(response) {
    });     
  }

  function refreshPlants(query) {
    plantsService.getAll(query, function(response) {
      $scope.plants = response.data;
    },
    function(response) {
    });     
  }

  refreshNurseries($scope.queryNursery);
  refreshPlants($scope.queryPlants);

  $scope.show_nursery = function(id) {
    nurseriesService.get(id, function(response) {
      $scope.sel_nursery = response;
      $scope.sel_nursery_taken_buckets = new Array();
      for (i = 0; i < $scope.sel_nursery.buckets.length; i++) {
        $scope.sel_nursery_taken_buckets.push($scope.sel_nursery.buckets[i].position);
      }
      $scope.template = '/nursery-show.html';
    }, 
    function(response) {
    });
  }

  $scope.remove_nursery = function(id) {
    nurseriesService.delete(id, 
      function(result) {
        refreshNurseries($scope.queryNursery);
        refreshPlants($scope.queryPlants);
      },
      function(result) {
      });
  }

  $scope.add_nursery = function() {
    $scope.new_nursery = { name: "", type: "nursery", dimensions: { length: 1, width: 1 } };
    $scope.template = '/nursery-add.html';
  }

  $scope.save_nursery = function() {  
    nurseriesService.post($scope.new_nursery, 
      function(result) {
        refreshNurseries($scope.queryNursery);
        $scope.show_nursery(result._id);
      },
      function(result) {
      });
  }

  $scope.set_plant_in_bucket = function(plant_id) {
    plantsService.patch_set_plant_in_bucket(plant_id, $scope.sel_nursery._id, $scope.sel_bucket_pos,  
      function(result) {
        $scope.show_nursery($scope.sel_nursery._id);
        refreshPlants();
      },
      function(result) {
      });
  }

  $scope.remove_plant_from_bucket = function(plant_id) {
    plantsService.patch_remove_plant_from_bucket(plant_id, 
      function(result) {
        $scope.show_nursery($scope.sel_nursery._id);
        refreshPlants();
      },
      function(result) {
      });
  }

  $scope.add_plant = function() {
    plant_typesService.getAll(
      function(result) {
        $scope.plant_types = result.data;
        $scope.plant_selected = { code: 0, creation_date: new Date(), type_id: $scope.plant_types[0]._id };
        $scope.template = '/plant_add.html'; 
      },
      function(result) {

      });
  }

    $scope.remove_plant = function(plant_id) {
      plantsService.delete(plant_id,
        function(result) {
          refreshPlants();
          $scope.show_nursery($scope.sel_nursery._id);
        }, 
        function(result) {
        });
  }

  $scope.show_plant = function(plant_id) {
    plant_typesService.getAll(
      function(result) {
       $scope.plant_types = result.data;
       plantsService.get(plant_id,
          function(result) {
            $scope.plant_selected = result;
            $scope.plant_selected.creation_date = new Date($scope.plant_selected.creation_date);
            $scope.template = '/plant_show.html';
          }, 
          function(result) {
          });
      },
      function(result) {

      });    
  }

  $scope.update_plant = function() {
    plantsService.put($scope.plant_selected._id, $scope.plant_selected,
      function(result) {
        refreshPlants();
        $scope.show_nursery($scope.sel_nursery._id);
      },
      function(result) {
      });
  }

  $scope.save_plant = function() {
    plantsService.post($scope.plant_selected,
      function(result) {
        refreshPlants();
        $scope.show_nursery($scope.sel_nursery._id);
      },
      function(result) {
      });
  }
});