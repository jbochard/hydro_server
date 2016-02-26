import {Injectable} 								from 'angular2/core'
import {Http, Response, Headers, RequestOptions}	from 'angular2/http'
import {Observable} 								from 'rxjs/Observable';
import {Config}                                   	from './config'
import 'rxjs/Rx';

@Injectable()
export class SensorService {

	sensors: Object;
	url: string;

	constructor(private http: Http) {
	    this.url = Config.server_url + '/sensors';  
	}

	getAll() {
		return this.http
			.get(this.url)
			.map(res => res.json())
			.catch(this.handleError);
   	}

	setEnableSensor(id, value) {
		let body = JSON.stringify({ op: 'ENABLE_SENSOR', enable: value });
    	let headers = new Headers({ 'Content-Type': 'application/json' });
    	let options = new RequestOptions({ headers: headers });

    	return this.http
    		.patch(this.url + '/' + id, body, options)
            .map(res => res.json() )
            .catch(this.handleError)
   	}

   	private handleError(error: Response) {
   		return Observable.throw(error.json().error || 'Server error');
   	}
}
