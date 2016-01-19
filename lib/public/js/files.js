ang.service('filesService', ['$http', function($http) {
		this.getAll = function(query, result) {
			var url = host + '/files/';
			if (query != null && query.length > 0) {
				url = url + '?query='+query;
			}
			$http.get(url)
			.then(
				function(data) {
				  	result(data);
				 },
				function(data) {
				}
			);
		};

		this.getConfigModules = function(resultFn, errorFn) {
			$http.get(host + '/files/config/modules')
			.then(
				function(result) {
				  	resultFn(result.data);
				 },
				function(data) {
					errorFn(result.data);
				}
			);
		};

		this.getConfigMethods = function(resultFn, errorFn) {
			$http.get(host + '/files/config/methods')
			.then(
				function(result) {
				  	resultFn(result.data);
				 },
				function(data) {
					errorFn(result.data);
				}
			);
		};
		
		this.getByKey = function(key, result) {
			$http.get(host + '/files/' + key)
			.then(
				function(data) {
				  	result(data);
				},
				function(data) {
				}
			);
		};

		this.post = function(data, resultFn, errorFn) {
			$http.post(host + '/files', data)
			.then(
				function(data) {
				  	resultFn(data);
				}, 
				function(data) {
					errorFn(data);
				}
			);
		};

		this.putByKey = function(key, data, resultFn, errorFn) {
			$http.put(host + '/files/' + key, data)
			.then(
				function(data) {
				  	resultFn(data);
				}, 
				function(data) {
					errorFn(data);
				}
			);
		};

		this.duplicateByKey = function(key, resultFn, errorFn) {
			$http.post(host + '/files/' + key)
			.then(
				function(data) {
				  	resultFn(data);
				}, 
				function(data) {
					errorFn(data);
				}
			);
		};

		this.patchByKey = function(key, data, resultFn, errorFn) {
			$http.patch(host + '/files/' + key, data)
			.then(
				function(data) {
				  	resultFn(data);
				}, 
				function(data) {
					errorFn(data);
				}
			);
		};	

		this.delete = function(files, resultFn, errorFn) {
			$http.delete(host + '/files/', { data: files })
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

ang.controller('FilesController', function($scope, filesService) {

		function refreshFiles(query) {
	 		filesService.getAll(query, function(response) {
	 			$scope.files = response.data;
				$scope.keyEditedº = null;
				$scope.file_body = null;
	  		});			
		}
 
 		refreshFiles();

 		$scope.search = function() {
			refreshFiles($scope.search_value);
 		}

 		$scope.checkAll = function() {
 			for(k in $scope.files) {
 				$scope.files[k].selected = true;
 			}
 		}

 		$scope.uncheckAll = function() {
 			for(k in $scope.files) {
 				$scope.files[k].selected = false;
 			}
 		}

 		$scope.add = function() {
  			filesService.getConfigMethods(
  				function(response) {
  					$scope.methods = response;

		  			filesService.getConfigModules(
		  				function(response) {
		  					$scope.modules = response;

				 			$scope.file_body = { name: '<nombre>', method: 'GET', module: 'OSS', url: 'http://<host>', request: {}, response: {}, response_code: 200 };	
							$scope.showAddDlg = true;  			
		  				}, 
		  				function(error) {
		  				});  				
		  		}, 
  				function(error) {
  				}); 			
  		}

  		$scope.edit = function(key) {
  			filesService.getConfigMethods(
  				function(response) {
  					$scope.methods = response;

		  			filesService.getConfigModules(
		  				function(response) {
		  					$scope.modules = response;

				  			filesService.getByKey(key, function(response) {
				  				$scope.file_body = response.data;
				  				$scope.keyEdited = key;
				  				$scope.showEditDlg = true;
				  			});
		  				}, 
		  				function(error) {
		  				});  				
		  		}, 
  				function(error) {
  				});
  		}

  		$scope.saveAdd = function() {
			$scope.showAddDlg = false;

  			filesService.post($scope.file_body, 
  				function(response) {
  					refreshFiles($scope.search_value);
  				},
  				function(error) {	
 					refreshFiles($scope.search_value);
  				}
  			);
  		}

  		$scope.saveEdit = function(key, request) {
			$scope.showEditDlg = false;

  			filesService.putByKey(key, $scope.file_body, 
  				function(response) {
  					refreshFiles($scope.search_value);
  				},
  				function(error) {	
 					refreshFiles($scope.search_value);
  				}
  			);
  		}

 		$scope.clone = function(key) {
  			filesService.duplicateByKey(key, 
  				function(response) {
  					refreshFiles($scope.search_value);
  				},
  				function(error) {	
 					refreshFiles($scope.search_value);
  				}
  			);
  		}

  		$scope.close = function() {
			$scope.showEditDlg = false;
  		}

  		$scope.delete = function() {
  		 	var filesDelete = [];
  		 	for(k in $scope.files) {
  		 		if ($scope.files[k].selected) {
  		 			filesDelete.push($scope.files[k].name);
  		 		}
  		 	}

  			filesService.delete(filesDelete,
  				function(response) {
  					refreshFiles($scope.search_value);
  				},
  				function(error) {	
  				}
  			);
  		}

  		$scope.switch_lock = function(key) {
  			filesService.patchByKey(key, { "op": "switch", "path": "/lock" }, 
  				function(response) {
  					refreshFiles($scope.search_value);
  				},
  				function(error) {	
 					refreshFiles($scope.search_value);
  				}
  			);			
  		}
  	});
