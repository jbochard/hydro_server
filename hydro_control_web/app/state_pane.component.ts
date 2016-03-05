import {Component, OnInit}  from 'angular2/core'
import {Pipe, PipeTransform} from 'angular2/core';
import {SensorService}  		from './sensor.service'

@Pipe({name: 'category'})
export class CategoryPipe implements PipeTransform {
    transform(items: any[], args: any[]): any {
        return items.filter(item => item.category == args[0]);
    }
}

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
        <div id="collapseOne" class="container-fluid panel-collapse collapse in" role="tabpanel" aria-labelledby="client1">
          <div class="row">
            <div *ngFor="#col of client.value | category:'OUTPUT'" class="col-xs-6 col-sm-4 col-md-4 col-lg-2">
              <div class="sensor card card-block card-inverse text-xs-center" [class.card-success]="col.enable" [class.card-warning]="! col.enable">
                <div (click)="enableSensor(col)">
                  <h6 class="card-title">{{col.name}}</h6>
                  <p class="card-text">{{col.value}}</p>
                </div>
               </div>
            </div>
          </div>
          <div class="row">
            <div *ngFor="#col of client.value | category:'INPUT'" class="col-xs-6 col-sm-4 col-md-4 col-lg-2">
              <div class="sensor card card-block card-inverse text-xs-center" [class.card-success]="col.enable" [class.card-warning]="! col.enable">
                <div>
                  <i class="fa fa-hand-pointer-o" *ngIf="col.control == 'manual'  && ! col.enable"></i>
                  <i class="fa fa-cog"            *ngIf="col.control == 'rule'    && ! col.enable"></i>
                  <a (click)="controlSensor(col)" *ngIf="col.control == 'manual'  && col.enable"><i class="fa fa-hand-pointer-o"></i></a>
                  <a (click)="controlSensor(col)" *ngIf="col.control == 'rule'    && col.enable"><i class="fa fa-cog"></i></a>
                </div>
                <div (click)="enableSensor(col)">
                  <h6 class="card-title">{{col.name}}</h6>
                </div>
                <div class="btn-group btn-group-sm" role="group">
                  <i class="fa fa-toggle-off" *ngIf="col.value == 'OFF' && col.control == 'rule' "></i>
                  <i class="fa fa-toggle-on"  *ngIf="col.value == 'ON'  && col.control == 'rule' "></i>

                  <a *ngIf="col.value == 'OFF' && col.enable && col.control == 'manual'"
                        (click)="switchSensor(col, 'ON')" >
                    <i class="fa fa-toggle-off"></i>
                  </a>
                  <a *ngIf="col.value == 'ON' && col.enable && col.control == 'manual'"
                        (click)="switchSensor(col, 'OFF')" >
                    <i class="fa fa-toggle-on"></i>
                  </a>
                  <a *ngIf="col.value != 'ON' && col.value != 'OFF' "
                        (click)="switchSensor(col, 'OFF')" >
                    <i class="fa fa-medkit"></i>
                  </a>
                </div>                
              </div>
            </div>           
          </div>
        </div>
      </div>
    </div>

    <div class="modal fade" id="confirmDialog" tabindex="-1" role="dialog" aria-labelledby="confirmDialogLabel" 
      aria-hidden="true">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close">
              <span aria-hidden="true">&times;</span>
            </button>
            <h4 class="modal-title" id="confirmDialogLabel">{{confirmDialog.title}}</h4>
          </div>
          <div class="modal-body">
            <div class="container-fluid"> 
              <div class="row">
                <div class="col-xs-12">
                  {{confirmDialog.message}}
                </div>
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-primary" (click)="confirmDialogAccept()">Aceptar</button>
            <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
          </div>
        </div>
      </div>
    </div>
    `,
     providers: [ SensorService ],
     pipes: [ CategoryPipe ]
})

export class StatePane implements OnInit {

	clients: Object;
  confirmDialog = { title: "", message: "", accept: function() {} };
	errorMessage = "";
  clientUrl: string;

  private timer: number; 
  private columns: number;

	constructor( private _sensorService: SensorService ) {
     this.updateSensors();
  }

  openConfirmDialog(title, message, acceptFn) {
    this.confirmDialog.title = title;
    this.confirmDialog.message = message;
    this.confirmDialog.accept = acceptFn;

    $('#confirmDialog').modal('show');
  }

  confirmDialogAccept() {
    $('#confirmDialog').modal('hide');  
    this.confirmDialog.title = "";
    this.confirmDialog.message = "";
    this.confirmDialog.accept();
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

  deleteAllSensors(url) {
    this.openConfirmDialog("Atención", "Esta seguro que desea eliminar los sensores?", 
      () => this._sensorService.delete(url)
        .subscribe(
          response => this.updateSensors(),
          error => this.errorMessage = error
      )
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
