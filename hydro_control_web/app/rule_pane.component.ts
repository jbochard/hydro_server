import {Component, OnInit}      from 'angular2/core'
import {RuleService} 	 		from './rule.service'

@Component({
  selector: 'rule-pane',
  template: `
  	<span *ngIf='errorMessage != null'>{{errorMessage}}</span>
	<table class="table table-xs">
	  <thead>
	    <tr>
	      <th>Nombre</th>
	      <th>Condición</th>
	      <th>Descripción</th>
	      <th>Última ejecución</th>
	      <th>Estado</th>
	      <th></th>
	    </tr>
	  </thead>
	  <tbody>
	    <tr *ngFor="#rule of rules" [class.table-warning]="rule.active">
	      <td>{{rule.name}}</td>
	      <td>{{rule.condition}}</td>
	      <td>{{rule.description}}</td>
	      <td>{{rule.status.last_evaluation}}</td>
	      <td style="cursor: pointer" (click)="showStatusRule(rule)" data-toggle="modal" data-target="#statusRuleModal">{{rule.status.status}}</td>
	      <td><a style="cursor: pointer" (click)="editRule(rule)" data-toggle="modal" data-target="#editRuleModal"><i class="fa fa-pencil-square-o"></i></a></td>
	    </tr>
	  </tbody>
	</table>

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
				      <h4 class="panel-title">
				        <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
				          Contexto
				        </a>
				      </h4>
				    </div>
				    <div id="collapseOne" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
				    	<h6>{{statusRule.context}}</h6>
				    </div>
				  </div>
	 			  <div class="panel panel-default">
				    <div class="panel-heading" role="tab" id="headingOne">
				      <h4 class="panel-title">
				        <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
				          Error
				        </a>
				      </h4>
				    </div>
				    <div *ngIf="selectedRule.status?.backtrace != null" id="collapseOne" class="panel-collapse collapse in" role="tabpanel" aria-labelledby="headingOne">
				    	<h6>{{statusRule.backtrace}}</h6>
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

export class RulePane {

	rules: Object;
	selectedRule: Object;
	statusRule: Object;
	errorMessage: string;

	constructor(private _ruleService: RuleService) { 
		this.updateRules();
		this.selectedRule = { name: "", description: "", enable: false, condition: "", action: "", status: {} };
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

	showStatusRule(rule) {
		this.statusRule = { 
			status: rule.status.status, 
			last_evaluation: rule.status.last_evaluation, 
			context: beautify(rule.status.context, null, 2, 100), 
			backtrace: JSON.stringify(rule.status.backtrace) 
		};
	}

	editRule(rule) {
		this.selectedRule = rule;
	}

	saveRule() {
		// $('#editRuleModal').modal('hide');
		this._ruleService
			.put(this.selectedRule)
			.subscribe(
				rules => this.selectedRule = { name: "", description: "", enable: false, condition: "", action: "", status: {} },
				error => this.errorMessage = error
			);	
	}
}
