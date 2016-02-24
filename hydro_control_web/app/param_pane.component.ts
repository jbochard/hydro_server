import {Component, OnInit}      from 'angular2/core'
import {ParamService} 	 		from './param.service'

@Component({
  selector: 'param-pane',
  template: `
  	<span *ngIf='errorMessage != null'>{{errorMessage}}</span>
	<table class="table table-xs">
	  <thead>
	    <tr>
	      <th>Nombre</th>
	      <th>Valor</th>
	      <th></th>
	    </tr>
	  </thead>
	  <tbody>
	    <tr *ngFor="#param of params">
	      <td>{{param.name}}</td>
	      <td>{{param.value}}</td>
	      <td>
	      	<a style="cursor: pointer" (click)="editParam(param)" data-toggle="modal" data-target="#editParamModal">
	      		<i class="fa fa-pencil-square-o"></i>
	      	</a>
	      	<a style="cursor: pointer" (click)="deleteParam(param)">
	      		<i class="fa fa-times"></i>
	      	</a>
	      </td>
	    </tr>
	  </tbody>
	</table>
	<button type="button" (click)="addParam()" class="btn btn-primary" data-toggle="modal" data-target="#editParamModal">
		Crear
	</button>

	<div class="modal fade" id="editParamModal" tabindex="-1" role="dialog" aria-labelledby="editParamLabel" aria-hidden="true">
	  <div class="modal-dialog" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
	        <h4 class="modal-title" id="editParamLabel">Editar parámetro</h4>
	      </div>
	      <div class="modal-body">
			<fieldset class="form-group">
				<label for="editParamName">Nombre</label>
				<input [(ngModel)]="selectedParam.name" type="string" class="form-control" id="editParamName" placeholder="Nombre">
				<small class="text-muted">Nombre del parámetro</small>
			</fieldset>
			<fieldset class="form-group">
				<label for="editParamValue">Valor</label>
				<input [(ngModel)]="selectedParam.value" type="string" class="form-control" id="editParamValue" placeholder="Valor">
				<small class="text-muted">Valor del parámetro</small>
			</fieldset>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
	        <button type="button" class="btn btn-primary" (click)="saveParam()">Guardar</button>
	      </div>
	    </div>
	  </div>
	</div>	
    `,
     providers: [ ParamService ]
})

export class ParamPane {

	params: Object;
	selectedParam: Object;
	errorMessage: string;

	constructor(private _paramService: ParamService) { 
		this.updateParams();
		this.selectedParam = { name: "", value: 0.0 };
	}

	updateParams() {
		this.errorMessage = "";
		this._paramService
			.getAll()
			.subscribe(
				params => this.params = params,
				error => this.errorMessage = error
			);
	}

	addParam() {
		this.selectedParam = { name: "", value: 0.0 };
		this.selectedMode = "create";
	}

	editParam(param) {
		this.selectedParam = param;
		this.selectedMode = "edit";		
	}

	saveParam() {
		$('#editParamModal').modal('hide');
		if (this.selectedMode == 'create') {
			this._paramService
				.post(this.selectedParam)
				.subscribe(
					res => this.updateParams(),
					error => this.errorMessage = error
				);
			return ;
		}
		if (this.selectedMode == 'edit') {
			this._paramService
				.put(this.selectedParam)
				.subscribe(
					res => this.updateParams(),
					error => this.errorMessage = error
				);
			return ;		
		}
	}

	deleteParam(param) {
		this._paramService
			.delete(param)
			.subscribe(
				res => this.updateParams(),
				error => this.errorMessage = error
			);
	}
}
