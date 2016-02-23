import {Component}      from 'angular2/core';
import {UiTabs, UiPane} from './ui_tabs';
import {StatePane}      from './state_pane.component';
import {RulePane}       from './rule_pane.component';

@Component({
  selector: 'hydro_control',
  template: `
    <h4>Hydro-Control</h4>
    <ui-tabs>
      <template ui-pane title='Estado' active="true">
        <state-pane></state-pane>
      </template>
      <template ui-pane title="Parámetros"></template>
      <template ui-pane title="Reglas">
        <rule-pane></rule-pane>
      </template>    
    </ui-tabs>
    <hr>
    `,
    directives: [UiTabs, UiPane, StatePane, RulePane]
})

export class HydroControl {

}
