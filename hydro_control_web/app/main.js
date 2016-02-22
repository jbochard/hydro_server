System.register(['angular2/platform/browser', './hydro_control.component', 'angular2/http'], function(exports_1) {
    var browser_1, hydro_control_component_1, http_1;
    return {
        setters:[
            function (browser_1_1) {
                browser_1 = browser_1_1;
            },
            function (hydro_control_component_1_1) {
                hydro_control_component_1 = hydro_control_component_1_1;
            },
            function (http_1_1) {
                http_1 = http_1_1;
            }],
        execute: function() {
            browser_1.bootstrap(hydro_control_component_1.HydroControl, [http_1.HTTP_PROVIDERS]);
        }
    }
});
//# sourceMappingURL=main.js.map