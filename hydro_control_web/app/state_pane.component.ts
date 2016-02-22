import {Component, OnInit}      from 'angular2/core'
import {SensorService}  		from './sensor.service'

@Component({
  selector: 'state-pane',
  template: `
     <ul>
      <li *ngFor="#sensor of sensors">
        {{ sensor.name }}
        {{ sensor.value }}
      </li>
    </ul>
    `,
     providers: [ SensorService ]

})

export class StatePane implements OnInit {

	sensors: Object;
	errorMessage: string;

  	constructor(private _sensorService: SensorService) { }

	updateSensors() {
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
