System.register([], function(exports_1) {
    var Sensor;
    return {
        setters:[],
        execute: function() {
            Sensor = (function () {
                function Sensor(_id, category, name, type, enable) {
                    this._id = _id;
                    this.category = category;
                    this.name = name;
                    this.type = type;
                    this.enable = enable;
                }
                return Sensor;
            })();
            exports_1("Sensor", Sensor);
        }
    }
});
//# sourceMappingURL=sensor.js.map