import {Component, OnInit}  from 'angular2/core'
import {SensorService}  		from './sensor.service'

@Component({
  selector: 'state-pane',
  template: `
  	<span *ngIf='errorMessage != null'>{{errorMessage}}</span>

    <div class="input-group" style="padding-top: 20px; padding-bottom: 20px; padding-left: 10px; padding-right: 10px">
      <input type="text" class="form-control" [(ngModel)]="clientUrl" placeholder="Url de cliente">
      <span class="input-group-btn">
        <button class="btn btn-secondary" type="button" (click)="createSensors()">Agregar!</button>
      </span>
    </div>

    <div id="accordion" role="tablist" aria-multiselectable="true" *ngFor="#client of clients">
       <div class="panel panel-default">
        <div class="panel-heading" role="tab" id="client1">
          <div class="row">
            <div class="col-xs-11">
              <h4 class="panel-title">
                <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                   {{client.name}}
                </a>
              </h4>
            </div>
            <div class="col-xs-1">
              <a (click)="deleteAllSensors(client.url)"><i class="fa fa-times"></i></a>
            </div>
          </div>
        </div>   
        <div id="collapseOne" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="client1">
          <div *ngFor="#rows of client.value" class="row">
            <div *ngFor="#col of rows" class="col-xs-2">
              <div class="sensor card card-block card-inverse text-xs-center" [class.card-success]="col.enable" [class.card-warning]="! col.enable">
                <div>
                  <i class="fa fa-hand-pointer-o" *ngIf="col.control == 'manual' && ! col.enable"></i>
                  <i class="fa fa-cog" *ngIf="col.control == 'rule' && ! col.enable"></i>
                  <a (click)="controlSensor(col)" *ngIf="col.control == 'manual' && col.enable"><i class="fa fa-hand-pointer-o"></i></a>
                  <a (click)="controlSensor(col)" *ngIf="col.control == 'rule' && col.enable"><i class="fa fa-cog"></i></a>
                </div>
                <div (click)="enableSensor(col)">
                  <h6 class="card-title">{{col.name}}</h6>
                  <p class="card-text" *ngIf="col.category == 'OUTPUT'">{{col.value}}</p>
                </div>
                <div class="btn-group btn-group-sm" role="group">
                  <button type="button" class="btn" [disabled]="!col.enable || col.control == 'rule'" [class.btn-secondary]="col.value == 'ON'" [class.btn-primary]="col.value == 'OFF'" *ngIf="col.category == 'INPUT'" (click)="switchSensor(col, 'ON')">ON</button>
                  <button type="button" class="btn" [disabled]="!col.enable || col.control == 'rule'" [class.btn-secondary]="col.value == 'OFF'" [class.btn-primary]="col.value == 'ON'" *ngIf="col.category == 'INPUT'" (click)="switchSensor(col, 'OFF')">OFF</button>
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
  clientUrl: string;
  private timer: number; 
  private columns: number;

	constructor(private _sensorService: SensorService) {
    this.columns = 5; 
    this.updateSensors();

  }

	updateSensors() {
		this.errorMessage = "";
		this._sensorService
			.getAllByClient(this.columns)
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

  deleteAllSensors(url) {
   this._sensorService.delete(url)
      .subscribe(
        response => this.updateSensors(),
        error => this.errorMessage = error
      );
  }

  createSensors() {
    this._sensorService.create(this.clientUrl)
      .subscribe(
        response => this.updateSensors(),
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
