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

	getAllByClient(cols) {
		return this.http
			.get(this.url+'?byClient=1&columns='+cols)
			.map(res => res.json())
			.catch(this.handleError);
   	}

	create(url) {
		let body = JSON.stringify({ url: url });
    	let headers = new Headers({ 'Content-Type': 'application/json' });
    	let options = new RequestOptions({ headers: headers });

    	return this.http
    		.post(this.url, body, options)
            .map(res => res.json() )
            .catch(this.handleError)
   	}

   	delete(url) {
    	let headers = new Headers({ 'Content-Type': 'application/json' });
    	let options = new RequestOptions({ headers: headers });

    	return this.http
    		.delete(this.url+'?url="'+url+'"', options)
            .map(res => res.json() )
            .catch(this.handleError)
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

    switchSensor(id, value) {
      let body = JSON.stringify({ op: 'SWITCH', value: value });
      let headers = new Headers({ 'Content-Type': 'application/json' });
      let options = new RequestOptions({ headers: headers });

      return this.http
        .patch(this.url + '/' + id, body, options)
            .map(res => res.json() )
            .catch(this.handleError)
    }

    controlSensor(id, value) {
      let body = JSON.stringify({ op: 'CONTROL', type: value });
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
