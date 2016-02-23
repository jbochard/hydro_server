System.register(['angular2/core', './sensor.service'], function(exports_1) {
    var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    };
    var __metadata = (this && this.__metadata) || function (k, v) {
        if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
    };
    var core_1, sensor_service_1;
    var StatePane;
    return {
        setters:[
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (sensor_service_1_1) {
                sensor_service_1 = sensor_service_1_1;
            }],
        execute: function() {
            StatePane = (function () {
                function StatePane(_sensorService) {
                    this._sensorService = _sensorService;
                    this.colums = 3;
                }
                StatePane.prototype.updateSensors = function () {
                    var _this = this;
                    this.errorMessage = "";
                    this._sensorService
                        .getAll()
                        .subscribe(function (sensors) {
                        _this.sensors = [];
                        var tmp = [];
                        var idx = 1;
                        for (var _i = 0; _i < sensors.length; _i++) {
                            var sensor = sensors[_i];
                            if (idx % _this.colums == 0) {
                                _this.sensors.push(tmp);
                                tmp = [];
                            }
                            tmp.push(sensor);
                            idx++;
                        }
                    }, function (error) { return _this.errorMessage = error; });
                };
                StatePane.prototype.ngOnInit = function () {
                    this.updateSensors();
                };
                StatePane = __decorate([
                    core_1.Component({
                        selector: 'state-pane',
                        template: "\n  \t<span *ngIf='errorMessage != null'>{{errorMessage}}</span>\n    <div *ngFor=\"#rows of sensors\" class=\"row\">\n      <div *ngFor=\"#col of rows\" class=\"col-xs-3\">\n        <div class=\"card card-inverse text-xs-center\" [class.card-success]=\"col.enable\" [class.card-warning]=\"! col.enable\">\n          <div class=\"card-block\">\n            <blockquote class=\"card-blockquote\">\n              <p>{{col.name}}</p>\n              <footer>{{col.value}}</footer>\n              <a href=\"#\" class=\"btn btn-primary\">Habilitar</a>\n            </blockquote>\n          </div>\n        </div>\n      </div>\n    </div>\n    ",
                        providers: [sensor_service_1.SensorService]
                    }), 
                    __metadata('design:paramtypes', [sensor_service_1.SensorService])
                ], StatePane);
                return StatePane;
            })();
            exports_1("StatePane", StatePane);
        }
    }
});
//# sourceMappingURL=state_pane.component.js.map