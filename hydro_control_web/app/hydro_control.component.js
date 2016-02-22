System.register(['angular2/core', './ui_tabs', './state_pane.component'], function(exports_1) {
    var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    };
    var __metadata = (this && this.__metadata) || function (k, v) {
        if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
    };
    var core_1, ui_tabs_1, state_pane_component_1;
    var HydroControl;
    return {
        setters:[
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (ui_tabs_1_1) {
                ui_tabs_1 = ui_tabs_1_1;
            },
            function (state_pane_component_1_1) {
                state_pane_component_1 = state_pane_component_1_1;
            }],
        execute: function() {
            HydroControl = (function () {
                function HydroControl() {
                }
                HydroControl = __decorate([
                    core_1.Component({
                        selector: 'hydro_control',
                        template: "\n    <h4>Hydro-Control</h4>\n    <ui-tabs>\n      <template ui-pane title='Estado' active=\"true\">\n        <state-pane></state-pane>\n      </template>\n      <template ui-pane title=\"Par\u00E1metros\"></template>\n      <template ui-pane title=\"Reglas\"></template>    \n    </ui-tabs>\n    <hr>\n    ",
                        directives: [ui_tabs_1.UiTabs, ui_tabs_1.UiPane, state_pane_component_1.StatePane]
                    }), 
                    __metadata('design:paramtypes', [])
                ], HydroControl);
                return HydroControl;
            })();
            exports_1("HydroControl", HydroControl);
        }
    }
});
//# sourceMappingURL=hydro_control.component.js.map