import {Injectable} 	from 'angular2/core'
import {Http, Response}	from 'angular2/http'
import {Observable} from 'rxjs/Observable';
import 'rxjs/Rx';

@Injectable()
export class SensorService {

	sensors: Object;

	constructor(private http: Http) {}

	getAll(response, errors) {
		var path = 'http://localhost:9490/sensors';
		return this.http
			.get(path)
			.map(res => res.json())
			.catch(this.handleError);
   	}

   	private handleError(error: Response) {
   		return Observable.throw(error.json().error || 'Server error');
   	}
}
