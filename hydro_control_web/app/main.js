System.register(['angular2/platform/browser', './hydro_control.component'], function(exports_1) {
    var browser_1, hydro_control_component_1;
    return {
        setters:[
            function (browser_1_1) {
                browser_1 = browser_1_1;
            },
            function (hydro_control_component_1_1) {
                hydro_control_component_1 = hydro_control_component_1_1;
            }],
        execute: function() {
            browser_1.bootstrap(hydro_control_component_1.HydroControl);
        }
    }
});
//# sourceMappingURL=main.js.map