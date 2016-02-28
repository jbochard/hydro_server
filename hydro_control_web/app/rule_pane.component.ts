/// <reference path="./bootstrap.d.ts"/>

import {Component, OnInit}      from 'angular2/core'
import {RuleService} 	 		from './rule.service'

@Component({
  selector: 'rule-pane',
  template: `
  	<span *ngIf='errorMessage != null'>{{errorMessage}}</span>
	<table class="table table-xs table-bordered" style="padding-top: 20px; padding-left: 10px; padding-right: 10px">
	  <thead>
	    <tr>
	      <th>Nombre</th>
	      <th>Descripción</th>
	      <th>Última ejecución</th>
	      <th>Estado</th>
	      <th></th>
	    </tr>
	  </thead>
	  <tbody>
	    <tr *ngFor="#rule of rules" [class.table-danger]="rule.status.status == 'ERROR'">
	      <td>{{rule.name}}</td>
	      <td>{{rule.description}}</td>
	      <td>{{rule.status.last_evaluation}}</td>
	      <td style="cursor: pointer" (click)="showStatusRule(rule)" data-toggle="modal" data-target="#statusRuleModal">{{rule.status.status}}</td>
	      <td>
	      	<a style="cursor: pointer" (click)="editRule(rule)" data-toggle="modal" data-target="#editRuleModal"><i class="fa fa-pencil-square-o"></i></a>
	      	<a style="cursor: pointer" (click)="deleteRule(rule)"><i class="fa fa-times"></i></a>
	      </td>
	    </tr>
	  </tbody>
	</table>
	<button type="button" (click)="addRule()" class="btn btn-primary" data-toggle="modal" data-target="#editRuleModal">
		Crear
	</button>

	<div class="modal fade" id="editRuleModal" tabindex="-1" role="dialog" aria-labelledby="editLabelRuleLabel" aria-hidden="true">
	  <div class="modal-dialog" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
	        <h4 class="modal-title" id="editLabelRuleLabel">Editar regla</h4>
	      </div>
	      <div class="modal-body">
			<fieldset class="form-group">
				<label for="editRuleModalName">Nombre</label>
				<input [(ngModel)]="selectedRule.name" type="string" class="form-control" id="editRuleModalName" placeholder="Nombre">
				<small class="text-muted">Nombre de la regla</small>
			</fieldset>
			<fieldset class="form-group">
				<label for="editRuleModalDesc">Description</label>
				<input [(ngModel)]="selectedRule.description" type="string" class="form-control" id="editRuleModalDesc" placeholder="Descripción">
				<small class="text-muted">Descripción de la regla</small>
			</fieldset>
			<fieldset class="form-group">
				<label for="editRuleModalCondition">Condición</label>
				<textarea [(ngModel)]="selectedRule.condition" class="form-control" id="editRuleModalCondition" rows="3"></textarea>
			</fieldset>
			<fieldset class="form-group">
				<label for="editRuleModalAction">Acción</label>
				<textarea [(ngModel)]="selectedRule.action" class="form-control" id="editRuleModalAction" rows="3"></textarea>
			</fieldset>
			<fieldset class="form-group">
				<label for="editRuleModalAction">Else</label>
				<textarea [(ngModel)]="selectedRule.else_action" class="form-control" id="editRuleModalAction" rows="3"></textarea>
			</fieldset>
			<fieldset class="form-group">
				<label for="editRuleModalEnable">Habilitada</label>
				<input id="editRuleModalEnable" type="checkbox" [(ngModel)]="selectedRule.enable">
			</fieldset>
	      </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cancelar</button>
	        <button type="button" class="btn btn-primary" (click)="saveRule()">Guardar</button>
	      </div>
	    </div>
	  </div>
	</div>

	<div class="modal fade" id="statusRuleModal" tabindex="-1" role="dialog" aria-labelledby="statusLabelRuleLabel" aria-hidden="true">
	  <div class="modal-dialog" role="document">
	    <div class="modal-content">
	      <div class="modal-header">
	        <button type="button" class="close" data-dismiss="modal" aria-label="Close">
	          <span aria-hidden="true">&times;</span>
	        </button>
	        <h4 class="modal-title" id="statusLabelRuleLabel">Estado de la regla</h4>
	      </div>
	      <div class="modal-body">
	      <div class="container-fluid"> 
	      	<div class="row">
	      	  <div class="col-xs-12">
	      	  	Ultima ejecución: {{statusRule.last_evaluation}}
	      	  </div>
	      	</div>
	      	<div class="row">
	      	  <div class="col-xs-12">
	      	  	Estado: {{statusRule.status }}
	      	  </div>
	      	</div>
	      	<div class="row">
	      	  <div class="col-xs-12">
				<div id="accordion" role="tablist" aria-multiselectable="true">
				  <div class="panel panel-default">
				    <div class="panel-heading" role="tab" id="headingOne">
				      <h6 class="panel-title">
				        <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
				          Contexto
				        </a>
				      </h6>
				    </div>
				    <div id="collapseOne" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
				    	<p>{{statusRule.context}}</p>
				    </div>
				  </div>
	 			  <div class="panel panel-default">
				    <div class="panel-heading" role="tab" id="headingTwo">
				      <h6 class="panel-title">
				        <a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo" aria-expanded="true" aria-controls="collapseTwo">
				          Error
				        </a>
				      </h6>
				    </div>
				    <div id="collapseTwo" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingTwo">
				    	<p>{{statusRule.backtrace}}</p>
				    </div>
				  </div>			  
				</div>
			</div>
		  </div>
		  </div>
	      <div class="modal-footer">
	        <button type="button" class="btn btn-secondary" data-dismiss="modal">Cerrar</button>
	      </div>
	    </div>
	  </div>
	</div>
    `,
     providers: [ RuleService ]
})

export class RulePane implements OnInit {

	rules: Object;
	selectedRule: Object;
	statusRule: Object;
	selectedRuleMode = "create";
	errorMessage: string;
	private timer: number; 

	constructor(private _ruleService: RuleService) { 
		this.updateRules();
		this.selectedRule = { name: "", description: "", enable: false, condition: "", action: "", else_action: "" };
		this.statusRule = { status: "", last_evaluation: "", context: [], backtrace: [] };
	}

	updateRules() {
		this.errorMessage = "";
		this._ruleService
			.getAll()
			.subscribe(
				rules => this.rules = rules,
				error => this.errorMessage = error
			);
	}

	addRule() {
		this.selectedRule = { name: "", description: "", enable: false, condition: "", action: "", else_action: "", status: {} };
		this.selectedRuleMode = "create";		
	}

	showStatusRule(rule) {
		if (rule.status != null) {
			this.statusRule = { 
				status: (rule.status.status != null)?rule.status.status: "", 
				last_evaluation: (rule.status.hasOwnProperty('last_evaluation'))?rule.status.last_evaluation: "", 
				context: (rule.status.context != null)?JSON.stringify(rule.status.context, null, 100): "{}", 
				backtrace: (rule.status.backtrace != null)?JSON.stringify(rule.status.backtrace, null, 80):"{}"
			};
		} else {
			this.statusRule = { 
				status: "NO", 
				last_evaluation: "", 
				context: "{}", 
				backtrace: "{}"
			};
		}
	}

	editRule(rule) {
		this.selectedRule = rule;
		this.selectedRuleMode = "edit";
	}

	saveRule() {
		$('#editRuleModal').modal('hide');
		if (this.selectedRuleMode == "edit") {
			this._ruleService
				.put(this.selectedRule)
				.subscribe(
					res => this.updateRules(),
					error => this.errorMessage = error
				);
			return;
		}
		if (this.selectedRuleMode == "create") {
			this._ruleService
				.post(this.selectedRule)
				.subscribe(
					res => this.updateRules(),
					error => this.errorMessage = error
				);
			return;
		}	
	}

	deleteRule(rule) {
		this._ruleService
			.delete(rule)
			.subscribe(
				res => this.updateRules(),
				error => this.errorMessage = error
			);
	}

	ngOnInit() {
    	this.timer = setInterval(_ => this.updateRules(), 10000);
	}

	ngOnDestroy() {
    	clearTimeout(this.timer);
	}
}
