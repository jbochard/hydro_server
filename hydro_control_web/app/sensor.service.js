System.register(['angular2/core', 'angular2/http', 'rxjs/Observable', 'rxjs/Rx'], function(exports_1) {
    var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
        var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
        if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
        else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
        return c > 3 && r && Object.defineProperty(target, key, r), r;
    };
    var __metadata = (this && this.__metadata) || function (k, v) {
        if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
    };
    var core_1, http_1, Observable_1;
    var SensorService;
    return {
        setters:[
            function (core_1_1) {
                core_1 = core_1_1;
            },
            function (http_1_1) {
                http_1 = http_1_1;
            },
            function (Observable_1_1) {
                Observable_1 = Observable_1_1;
            },
            function (_1) {}],
        execute: function() {
            SensorService = (function () {
                function SensorService(http) {
                    this.http = http;
                    this.url = 'http://localhost:9490/sensors';
                }
                SensorService.prototype.getAll = function () {
                    return this.http
                        .get(this.url)
                        .map(function (res) { return res.json(); })
                        .catch(this.handleError);
                };
                SensorService.prototype.setEnableSensor = function (id, value) {
                    var body = JSON.stringify({ op: 'ENABLE_SENSOR', enable: value });
                    var headers = new http_1.Headers({ 'Content-Type': 'application/json' });
                    var options = new http_1.RequestOptions({ headers: headers });
                    return this.http
                        .patch(this.url + '/' + id, body, options)
                        .map(function (res) { return res.json(); })
                        .catch(this.handleError);
                };
                SensorService.prototype.handleError = function (error) {
                    return Observable_1.Observable.throw(error.json().error || 'Server error');
                };
                SensorService = __decorate([
                    core_1.Injectable(), 
                    __metadata('design:paramtypes', [http_1.Http])
                ], SensorService);
                return SensorService;
            })();
            exports_1("SensorService", SensorService);
        }
    }
});
//# sourceMappingURL=sensor.service.js.map