ang.service('variableService', ['$http', function($http) {
		this.getAll = function(query, resultFn, errorFn) {
			var url = host + '/variables/';
			if (query != null && query.length > 0) {
				url = url + '?query='+query;
			}
			$http.get(url)
			.then(
				function(data) {
				  	resultFn(data);
				 },
				function(data) {
					errorFn(data);
				}
			);
		};

		this.post = function(ctx, k, v, resultFn, errorFn) {
			$http.post(host + '/variables/', {context: ctx, key: k, value:v })
			.then(
				function(data) {
				  	resultFn(data);
				}, 
				function(data) {
					errorFn(data);
				}
			);
		};

		this.delete = function(vars, resultFn, errorFn) {
			$http.delete(host + '/variables/', { data: vars })
			.then(
				function(data) {
				  	resultFn(data);
				}, 
				function(data) {
					errorFn(data);
				}
			);
		};
	}]);


ang.controller('VariablesController', function($scope, variableService) {

		function varsModel(data) {
			var result = [];
			for(var k in data) {
				result.push({ selected: false, context: data[k]['context'], key: data[k]['key'], value: data[k]['value'] });
			}
			return result;
		}

		function refresh(query) {
	 		variableService.getAll(query, function(response) {
	 			$scope.variables = varsModel(response.data);
	  		}, function(error) {

	  		});			
		}
 
 		refresh($scope.search_value);

 		$scope.checkAll = function() {
 			for(k in $scope.variables) {
 				$scope.variables[k].selected = true;
 			}
 		}

 		$scope.uncheckAll = function() {
 			for(k in $scope.variables) {
 				$scope.variables[k].selected = false;
 			}
 		}

 		$scope.add = function() {
 			$scope.contextEdt = '';
 			$scope.keyEdt = '';
 			$scope.valueEdt = '';
			$scope.showCxtDlg = true;
 		}  	

 		$scope.edit = function(ctx, key, value) {
 			$scope.showCxtDlg = true;
 			$scope.contextEdt = ctx;
 			$scope.keyEdt = key;
 			$scope.valueEdt = value;
 		}

		$scope.close = function() {
			$scope.showCxtDlg = false;
  		}

  		$scope.save = function(ctx, key, value) {
			$scope.showCxtDlg = false;
			variableService.post(ctx, key, value, 
				function(response) {
					refresh($scope.search_value);
				},
				function(response) {

				});
  		}

  		$scope.search = function() {
  			refresh($scope.search_value);
  		}

  		$scope.delete = function() {
  		 	var varsDelete = [];
  		 	for(k in $scope.variables) {
  		 		if ($scope.variables[k].selected) {
  		 			varsDelete.push({ context: $scope.variables[k].context, key: $scope.variables[k].key });
  		 		}
  		 	}

  			variableService.delete(varsDelete,
  				function(response) {
  					refresh($scope.search_value);
  				},
  				function(error) {	
  				}
  			);
  		}
  	});

