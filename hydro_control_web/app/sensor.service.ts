import {Injectable} 	from 'angular2/core'
import {Http, Response}	from 'angular2/http'
import 'rxjs/Rx';

@Injectable()
export class SensorService {

	sensors: Object;

	constructor(private http: Http) {}

	getAll() {
		var path = 'http://localhost:9490/sensors';
		return this.http
			.get(path)
			.map(res => res.json());
   	}
}
