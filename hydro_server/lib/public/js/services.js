ang.service('nurseriesService', ['$http', function($http) {

	this.getAll = function(query, resultFn, errorFn) {
		var url = host + '/nurseries/';
		if (query != null && query.length > 0) {
			url = url + '?query='+query;
		}

		$http.get(url).then(
			function(data) {
			  	resultFn(data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.get = function(id, resultFn, errorFn) {
		var url = host + '/nurseries/' + id;
		$http.get(url).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.post = function(data, resultFn, errorFn) {
		var url = host + '/nurseries';
		$http.post(url, data).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.put = function(nursery_id, data, resultFn, errorFn) {
		var url = host + '/nurseries/' + nursery_id;
		$http.put(url, data).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.change_water = function(nursery_id, resultFn, errorFn) {
		var url = host + '/nurseries/' + nursery_id;
		$http.patch(url, { op: 'CHANGE_WATER' }).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.fumigation = function(nursery_id, description, resultFn, errorFn) {
		var url = host + '/nurseries/' + nursery_id;
		$http.patch(url, { op: 'FUMIGATION', value: { description: description } }).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.register_mesurement = function(nursery_id, mesurement_type, mesurement_value, resultFn, errorFn) {
		var url = host + '/nurseries/' + nursery_id;
		$http.patch(url, { op: 'REGISTER_MESUREMENT', value: { type: mesurement_type, value: mesurement_value} }).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.delete = function(id, resultFn, errorFn) {
		var url = host + '/nurseries/' + id;
		$http.delete(url).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};
}]);

ang.service('plantsService', ['$http', function($http) {

	this.getAll = function(query, resultFn, errorFn) {
		var url = host + '/plants/';
		if (query != null && query.length > 0) {
			url = url + '?query='+query;
		}

		$http.get(url).then(
			function(data) {
			  	resultFn(data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.get = function(id, resultFn, errorFn) {
		var url = host + '/plants/' + id;
		$http.get(url).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.post = function(data, resultFn, errorFn) {
		var url = host + '/plants';
		$http.post(url, data).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.split = function(plant_id, resultFn, errorFn) {
		var url = host + '/plants/split/' + plant_id;
		$http.post(url, {}).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.put = function(plant_id, data, resultFn, errorFn) {
		var url = host + '/plants/' + plant_id;
		$http.put(url, data).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.register_growth = function(plant_id, value, resultFn, errorFn) {
		var url = host + '/plants/' + plant_id;
		$http.patch(url, { op: 'REGISTER_GROWTH', value: value }).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.patch_set_plant_in_bucket = function(plant_id, nursery_id, nursery_pos, resultFn, errorFn) {
		var url = host + '/plants/' + plant_id;
		var data = { op: "SET_PLANT_IN_BUCKET", value: { nursery_id: nursery_id, nursery_position: nursery_pos } };
		$http.patch(url, data).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.patch_remove_plant_from_bucket = function(plant_id, resultFn, errorFn) {
		var url = host + '/plants/' + plant_id;
		var data = { op: "REMOVE_PLANT_FROM_BUCKET", value: { plant_id: plant_id } };
		$http.patch(url, data).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};

	this.delete = function(id, resultFn, errorFn) {
		var url = host + '/plants/' + id;
		$http.delete(url).then(
			function(result) {
			  	resultFn(result.data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};
}]);

ang.service('plant_typesService', ['$http', function($http) {

	this.getAll = function(resultFn, errorFn) {
		var url = host + '/plant_types';
		$http.get(url).then(
			function(data) {
			  	resultFn(data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};
}]);

ang.service('mesurementsService', ['$http', function($http) {

	this.getAll = function(resultFn, errorFn) {
		var url = host + '/mesurements';
		$http.get(url).then(
			function(data) {
			  	resultFn(data);
			 },
			function(data) {
				errorFn(data);
			}
		);
	};
}]);