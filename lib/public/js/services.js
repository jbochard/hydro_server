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
