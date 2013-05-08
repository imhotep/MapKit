
(function() {

	var cordovaRef = window.PhoneGap || window.Cordova || window.cordova;

	var MapKit = function() {
		this.options = {
			height: 460,
			diameter: 1000,
			atBottom: true,
			lat: 49.281468,
			lon: -123.104446
		};

		this.mapType = {
            MAP_TYPE_NONE: 0, //No base map tiles.
            MAP_TYPE_NORMAL: 1, //Basic maps.
            MAP_TYPE_SATELLITE: 2, //Satellite maps with no labels.
            MAP_TYPE_TERRAIN: 3, //Terrain maps.
            MAP_TYPE_HYBRID: 4 //Satellite maps with a transparent layer of major streets.
        };

        this.iconColors = {
            HUE_RED: 0.0,
            HUE_ORANGE: 30.0,
            HUE_YELLOW: 60.0,
            HUE_GREEN: 120.0,
            HUE_CYAN: 180.0,
            HUE_AZURE: 210.0,
            HUE_BLUE: 240.0,
            HUE_VIOLET: 270.0,
            HUE_MAGENTA: 300.0,
            HUE_ROSE: 330.0
        };
	};

	MapKit.prototype = {

		showMap: function(success, error) {
			cordovaRef.exec(success, error, 'MapKit', 'showMap', [this.options]);
		},

		addMapPins: function(pins, success, error) {
			cordovaRef.exec(success, error, 'MapKit', 'addMapPins', [pins]);
		},

		clearMapPins: function(success, error) {
			cordovaRef.exec(success, error, 'MapKit', 'clearMapPins', []);
		},

		hideMap: function(success, error) {
			cordovaRef.exec(success, error, 'MapKit', 'hideMap', []);
		},

		changeMapType: function(mapType, success, error) {
			cordovaRef.exec(success, error, 'MapKit', 'changeMapType', [mapType ? { "mapType": mapType } :{ "mapType": 0 }]);
		}

	};

	cordovaRef.addConstructor(function() {
		window.mapKit = new MapKit();
	});

})();
