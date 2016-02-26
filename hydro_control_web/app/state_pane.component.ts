import {Component, OnInit}  from 'angular2/core'
import {SensorService}  		from './sensor.service'

@Component({
  selector: 'state-pane',
  template: `
  	<span *ngIf='errorMessage != null'>{{errorMessage}}</span>

    <div id="accordion" role="tablist" aria-multiselectable="true" *ngFor="#client of clients">
       <div class="panel panel-default">
        <div class="panel-heading" role="tab" id="headingOne">
          <h4 class="panel-title">
            <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
              {{client.name}}
            </a>
          </h4>
        </div>   
        <div id="collapseOne" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
          <div *ngFor="#rows of client.value" class="row">
            <div *ngFor="#col of rows" class="col-xs-2">
              <div class="sensor card card-inverse text-xs-center" [class.card-success]="col.enable" [class.card-warning]="! col.enable">
                <div class="card-block" (click)="enableSensor(col)">
                  <blockquote *ngIf="col.category == 'OUTPUT'" class="card-blockquote">
                    <p>{{col.name}}</p>
                    <footer>{{col.value}}</footer>
                  </blockquote>
                  <blockquote *ngIf="col.category == 'INPUT'" class="card-blockquote">
                    <p>{{col.name}}</p>
                    <footer>{{col.value}}</footer>
                  </blockquote>

                  <button type="button" class="btn btn-primary" data-toggle="button" aria-pressed="false" autocomplete="off">
  Single toggle
</button>

                </div>
              </div>
            </div>
          </div>     
        </div>
      </div>
    </div>
    `,
     providers: [ SensorService ]
})

export class StatePane implements OnInit {

	clients: Object;
	errorMessage: string;
  private timer: number; 

	constructor(private _sensorService: SensorService) { 
    this.updateSensors();
  }

	updateSensors() {
		this.errorMessage = "";
		this._sensorService
			.getAllByClient()
			.subscribe(
				clients => this.clients = clients,
				error => this.errorMessage = error);
	}

  enableSensor(sensor) {
    this._sensorService.setEnableSensor(sensor._id, !sensor.enable)
      .subscribe(
        response => sensor.enable = response.state,
        error => this.errorMessage = error
      );
  }

  controlSensor(sensor) {
    var type = sensor.control;
    if (type == "rule") {
      type = "manual";
    } else {
      type = "rule";
    } 
    this._sensorService.controlSensor(sensor._id, type)
      .subscribe(
        response => sensor.control = response.control,
        error => this.errorMessage = error
      );
  }


  switchSensor(sensor, value) {
    this._sensorService.switchSensor(sensor._id, value)
      .subscribe(
        response => sensor.value = response.state,
        error => this.errorMessage = error
      );
  }

	ngOnInit() {
    this.timer = setInterval(_ => this.updateSensors(), 5000);
	}

  ngOnDestroy() {
    clearTimeout(this.timer);
  }
}
