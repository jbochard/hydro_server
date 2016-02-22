import {Injectable} from 'angular2/core';
import {Http} 		from 'angular2/http';

@Injectable()
export class SensorService {

	constructor(private http: Http) {

	getAll() {
		var path = '/sensors';
    	return this.http.get(path);
   	}
}
