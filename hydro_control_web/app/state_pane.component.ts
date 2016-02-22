import {Component}      from 'angular2/core';
import {SensorService}  from './sensor.service.ts';

@Component({
  selector: 'state-pane',
  template: `
    Hola
    `,
     providers: [ SensorService ]

})

export class StatePane implements OnInit {

  constructor(private _sensorService: SensorService) { }

  updateSensors() {
     this._sensorService.getAll();
  }

  ngOnInit() {
    this.updateSensors();
  }
}
