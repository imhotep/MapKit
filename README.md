MapKit plugin for iOS and Android
=================================

Uses *Apple Maps* on iOS and *Google Maps v2* on Android

Currently only works/tested on Android and iOS. Requires Cordova 3.0+ (will not work on earlier versions without modifications).

![Cordova Map 1](http://i.imgur.com/Mf6oeXal.png)

![Cordova Map 2](http://i.imgur.com/XaaBGeGl.png)

![Cordova Map 3](http://i.imgur.com/3IoDj0Rl.png)

![Cordova Map 4](http://i.imgur.com/Bfzik6Ml.png)


Android specific
----------------

You need a [Google Maps Android v2 API KEY](https://code.google.com/apis/console/) from google and you need to specify it when you install the plugin

You can install this plugin with [plugman](https://npmjs.org/package/plugman)

    plugman install --platform android --project android-mapkit-example/ --plugin /path/to/MapKit --variable API_KEY="YOUR_API_KEY_FROM_GOOGLE"

or with cordova CLI

    cordova -d plugin add /path/to/MapKit --variable API_KEY="YOUR_API_KEY_FROM_GOOGLE"
	
(/path/to/MapKit could be the git repository https://github.com/imhotep/MapKit)


Sample code
-----------

    var app = {
        showMap: function() {
            var pins = [
            {
                lat: 49.28115,
                lon: -123.10450,
                title: "A Cool Title",
                snippet: "A Really Cool Snippet",
                icon: plugin.mapKit.iconColors.HUE_ROSE
            },
            {
                lat: 49.27503,
                lon: -123.12138,
                title: "A Cool Title, with no Snippet",
                icon: {
                  type: "asset",
                  resource: "www/img/logo.png", //an image in the asset directory
                  pinColor: plugin.mapKit.iconColors.HUE_VIOLET //iOS only
                }
            },
            {
                lat: 49.28286,
                lon: -123.11891,
                title: "Awesome Title",
                snippet: "Awesome Snippet",
                icon: plugin.mapKit.iconColors.HUE_GREEN
            }];
            var error = function() {
              console.log('error');
            };
            var success = function() {
              plugin.mapKit.addMapPins(pins, function() { 
                                          console.log('adMapPins success');  
                                      },
                                      function() { console.log('error'); });
            };
            plugin.mapKit.showMap(success, error);
        },
        hideMap: function() {
            var success = function() {
              console.log('Map hidden');
            };
            var error = function() {
              console.log('error');
            };
            plugin.mapKit.hideMap(success, error);
        },
        clearMapPins: function() {
            var success = function() {
              console.log('Map Pins cleared!');
            };
            var error = function() {
              console.log('error');
            };
            plugin.mapKit.clearMapPins(success, error);
        },
        changeMapType: function() {
            var success = function() {
              console.log('Map Type Changed');
            };
            var error = function() {
              console.log('error');
            };
            plugin.mapKit.changeMapType(mapKit.mapType.MAP_TYPE_SATELLITE, success, error);
        }
    }

Configuration
-------------

You can override the options by passing a suitable options object as arguments to showMap

    var options = {
      height: 460, // height of the map (width is always full size for now)
      diameter: 1000,   // unused for now
      atBottom: true,   // bottom or top of the webview
      lat: 49.281468,   // initial camera position latitude
      lon: -123.104446  // initial camera position latitude
    };

Sample App
----------

Checkout the sample/ application as a boilerplate!

Missing features
----------------

Info bubbles: Simple info bubbles supported (title, snippet and custom icons for markers). Custom info bubbles not supported (i.e HTML bubbles etc..).

License
-------

Apache
