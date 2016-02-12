
ang.controller('HydroponicController', function($scope, $location, $filter, nurseriesService, plantsService, plant_typesService, mesurementsService) {

  $scope.template = '';
  $scope.nurseries = [];
  $scope.plants = [];
  $scope.mesurements = []

  $scope.plant_types = {}; 
  $scope.nursery_types = [{ name: "Cajón", type: "drawer"}, { name: "Almácigo", type: "nursery"}, { name: "Maceta", type: "plantpot"}];

  $scope.new_nursery = {};
  $scope.sel_nursery = {};
  $scope.sel_bucket_pos = null;
  $scope.sel_nursery_taken_buckets = [];
  $scope.sel_nursery_max_water_change = null;

  $scope.sel_nursery_mesurement= { type: null, value: 0 };
  $scope.sel_plant_growth = { value: 0 };

  function showChangeWaterDlg() {
    $( "#changeWaterDlg" ).dialog("open");
  }

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
     $scope.plant_selected = {};
    if ($scope.is_bucket_taken(r, c)) {
       for (i = 0; i < $scope.plants.length; i++) {
          if ($scope.plants[i].bucket.nursery_id == $scope.sel_nursery._id && $scope.plants[i].bucket.nursery_position == $scope.sel_bucket_pos) {
            $scope.plant_selected = $scope.plants[i];
          }
        }
      }      
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

  function refreshMesurements() {
        mesurementsService.getAll(
      function(result) {
        $scope.mesurements = result.data;
        $scope.sel_nursery_mesurement.type = $scope.mesurements[0].type;
      },
      function(result) {

      });
  }

  refreshNurseries($scope.queryNursery);
  refreshPlants($scope.queryPlants);
  refreshMesurements();

  $scope.show_nursery = function(id) {
    nurseriesService.get(id, function(response) {
      $scope.sel_nursery = response;
      $scope.sel_bucket_pos = 1;
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
    $scope.new_nursery = { name: "", description: "", type: "nursery", dimensions: { length: 1, width: 1 } };
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

  $scope.edit_nursery = function() {
      $scope.template = '/nursery-edit.html';
  }

  $scope.update_nursery = function() {  
    nurseriesService.put($scope.sel_nursery._id, $scope.sel_nursery, 
      function(result) {
        refreshNurseries($scope.queryNursery);
        $scope.show_nursery($scope.sel_nursery._id);
      },
      function(result) {
      });
  }

  $scope.change_water = function() {
    nurseriesService.change_water($scope.sel_nursery._id, 
      function(result) {
        showChangeWaterDlg();
        $scope.show_nursery($scope.sel_nursery._id);        
      },
      function(result) {
      });    
  }

  $scope.register_mesurement = function() {
    nurseriesService.register_mesurement($scope.sel_nursery._id, $scope.sel_nursery_mesurement.type, $scope.sel_nursery_mesurement.value, 
      function(result) {
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

  $scope.split_plant = function(plant_id) {
      plantsService.split(plant_id,
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
            $scope.plant_selected.creation_date = $scope.plant_selected.creation_date;
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

  $scope.register_growth = function(plant_id) {
    plantsService.register_growth(plant_id, $scope.sel_plant_growth,
      function(result) {
        refreshPlants();
        $scope.show_nursery($scope.sel_nursery._id);
      }, 
      function(result) {

      });
  }
});