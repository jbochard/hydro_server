import {Injectable} 								              from 'angular2/core'
import {Http, Response, Headers, RequestOptions}	from 'angular2/http'
import {Observable} 								              from 'rxjs/Observable';
import 'rxjs/Rx';

@Injectable()
export class ParamService {

	url: string;

	constructor(private http: Http) {
		this.url = 'http://localhost:9490/parameters';
	}

	getAll() {
		return this.http
			.get(this.url)
			.map(res => res.json())
			.catch(this.handleError);
   	}
   	
  put(param) {
		let body = JSON.stringify(param);
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

		return this.http
    		.put(this.url + '/' + param._id, body, options)
            .map(res => res.json())
            .catch(this.handleError)
  }

  post(param) {
    let body = JSON.stringify(param);
    let headers = new Headers({ 'Content-Type': 'application/json' });
    let options = new RequestOptions({ headers: headers });

    return this.http
        .post(this.url, body, options)
            .map(res => res.json())
            .catch(this.handleError)
  }

  delete(param) {
    return this.http
      .delete(this.url + '/' + param._id)
      .map(res => res.json())
      .catch(this.handleError);
    }

  private handleError(error: Response) {
    return Observable.throw(error.json().error || 'Server error');
  }
}
