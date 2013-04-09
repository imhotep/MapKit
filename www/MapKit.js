
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
	}

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
		}

	};

	cordovaRef.addConstructor(function() {
		window.mapKit = new MapKit();
	});

})();
