import {Injectable} 								from 'angular2/core'
import {Http, Response, Headers, RequestOptions}	from 'angular2/http'
import {Observable} 								from 'rxjs/Observable';
import 'rxjs/Rx';

@Injectable()
export class RuleService {

	url: string;

	constructor(private http: Http) {
 		this.url = server_url + '/rules';
	}

	getAll() {
		return this.http
			.get(this.url)
			.map(res => res.json())
			.catch(this.handleError);
   	}
   	
  put(rule) {
		let body = JSON.stringify(rule);
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

		return this.http
    		.put(this.url + '/' + rule._id, body, options)
            .map(res => res.json())
            .catch(this.handleError)
  }

  post(rule) {
    let body = JSON.stringify(rule);
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    return this.http
        .post(this.url, body, options)
            .map(res => res.json())
            .catch(this.handleError)
  }

  delete(rule) {
    return this.http
      .delete(this.url + '/' + rule._id)
      .map(res => res.json())
      .catch(this.handleError);
    }

  private handleError(error: Response) {
    return Observable.throw(error.json().error || 'Server error');
  }
}
