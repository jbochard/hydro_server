import {Component, OnInit}      from 'angular2/core'
import {SensorService}  		from './sensor.service'

@Component({
  selector: 'state-pane',
  template: `
  	<span *ngIf='errorMessage != null'>{{errorMessage}}</span>
     <div class='list-group' *ngFor="#sensor of sensors">
      <a href='#' class='list-group-item'>
        <h4 class='list-group-item-heading'>{{ sensor.name }}</h4>
        <p class='list-group-item-text'>{{ sensor.value }}</p>
      </a>
    </div>
    `,
     providers: [ SensorService ]

})

export class StatePane implements OnInit {

	sensors: Object;
	errorMessage: string;

  	constructor(private _sensorService: SensorService) { }

	updateSensors() {
		this.errorMessage = "";
		this._sensorService
			.getAll()
			.subscribe(
				sensors => this.sensors = sensors,
				error => this.errorMessage = error);
	}

	ngOnInit() {
		this.updateSensors();
	}
}
