
(function() {

var cordovaRef = window.PhoneGap || window.Cordova || window.cordova; // old to new fallbacks

	/*
	* PhoneGap is available under *either* the terms of the modified BSD license *or* the
	* MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
	*
	* Copyright (c) 2005-2010, Nitobi Software Inc., Brett Rudd, Jesse MacFadyen
	*/

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
			cordovaRef.exec(success, error, 'MapKitView', 'showMap', []);
		},

		setMapData: function(success, error, options) {
			/*
			buttonCallback: String, string callback function
			height: Number, - pixels
			diameter: Number, - meters
			atBottom: Bool,
			lat: Number,
			lon: Number
			*/
			for (var v in options) {
				if (options.hasOwnProperty(v)) {
					this.options[v] = options[v];
				}
			}
			cordovaRef.exec(success, error, 'MapKitView', 'setMapData', [this.options]);
		},

		addMapPins: function(pins) {
			var pinStr = '[]';
			if (pins) {
				pinStr = JSON.stringify(pins);
			}
			cordovaRef.exec(success, error, 'MapKitView', 'addMapPins', [pinStr]);
		},

		clearMapPins: function(success, error) {
			cordovaRef.exec(success, error, 'MapKitView', 'clearMapPins', []);
		},

		hideMap: function() {
			cordovaRef.exec(success, error, 'MapKitView', 'hideMap', []);
		}

	};

	cordovaRef.addConstructor(function() {
		window.mapKit = new MapKit();
	});

})();
