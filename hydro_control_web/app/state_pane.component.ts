import {Component, OnInit}      from 'angular2/core'
import {SensorService}  		from './sensor.service'

@Component({
  selector: 'state-pane',
  template: `
    Hola
    `,
     providers: [ SensorService ]

})

export class StatePane implements OnInit {

	sensors: Object;

  	constructor(private _sensorService: SensorService) { }

	updateSensors() {
		this.sensors = this._sensorService.getAll();
	}

	ngOnInit() {
		this.updateSensors();
	}
}
