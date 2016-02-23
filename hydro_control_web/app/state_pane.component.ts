import {Component, OnInit}      from 'angular2/core'
import {SensorService}  		from './sensor.service'

@Component({
  selector: 'state-pane',
  template: `
  	<span *ngIf='errorMessage != null'>{{errorMessage}}</span>
    <div *ngFor="#rows of sensors" class="row">
      <div *ngFor="#col of rows" class="col-xs-3">
        <div class="card card-inverse text-xs-center" [class.card-success]="col.enable" [class.card-warning]="! col.enable">
          <div class="card-block">
            <blockquote class="card-blockquote">
              <p>{{col.name}}</p>
              <footer>{{col.value}}</footer>
              <a href="#" class="btn btn-primary">Habilitar</a>
            </blockquote>
          </div>
        </div>
      </div>
    </div>
    `,
     providers: [ SensorService ]
})

export class StatePane implements OnInit {

	sensors: Object;
	errorMessage: string;
  colums: integer;

	constructor(private _sensorService: SensorService) { 
    this.colums = 3;
  }

	updateSensors() {
		this.errorMessage = "";
		this._sensorService
			.getAll()
			.subscribe(
				sensors => {
          this.sensors = [];
          var tmp = [];
          var idx = 1;
          for (var sensor of sensors) {
            if (idx % this.colums == 0) {
              this.sensors.push(tmp);
              tmp = [];
            }
            tmp.push(sensor);
            idx++;
          }
        },
				error => this.errorMessage = error);
	}

	ngOnInit() {
		this.updateSensors();
	}
}
