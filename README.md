MapKit plugin for iOS and Android (FORK from Imhotep's excellent plugin)
========================================================================

Uses *Apple Maps* on iOS and *Google Maps v2* on Android

Currently only works/tested on Android and iOS. Requires Cordova 3.0+ (will not work on earlier versions without modifications).
NB : Advanced functionnalities (that differ from Imhotep's plugin) are only accessible for IOS at the moment. Android in progress.

![Cordova Map 1](http://www.benjamin-horner.com/img/2014-01-10 11.12.44.png)

![Cordova Map 2](http://www.benjamin-horner.com/img/2014-01-10 11.13.24.png)

Android specific
----------------

You need a [Google Maps Android v2 API KEY](https://code.google.com/apis/console/) from google and you need to specify it when you install the plugin

You can install this plugin with [plugman](https://npmjs.org/package/plugman)

    plugman install --platform android --project android-mapkit-example/ --plugin /path/to/MapKit --variable API_KEY="YOUR_API_KEY_FROM_GOOGLE"

or with cordova CLI

    cordova -d plugin add /path/to/MapKit --variable API_KEY="YOUR_API_KEY_FROM_GOOGLE"

(/path/to/MapKit could be the git repository https://github.com/imhotep/MapKit)


IOS specific
------------
As said in the title, this is a FORK from [Imhotep's excellent plugin](https://github.com/imhotep/MapKit). This fork adds numerous functionnalities for IOS ONLY.

Added methods :

moveMap(move, success, error) => This enables you to move the View containing the map (the Native one) within your view. But also to change size etc…

showDirections(directions, success, error) => This method draws the itinerary from point A to point B. You can pass a set of options, such as the transport type (defaut is automobile, options is walking), whether the starting point is the user's current position or coordinates you pass the method…

I have also added a little tweek to the original code by defaulting the map to center and resize to show ALL PINS when more than one pin is inserted.

Further methods (those where to serve my own needs) :

addInnerShadows() => for my design I needed an inner shadow at the top of my map.

addCloseButton() => Still in development stage.


Sample code
-----------

    var app = {
        showMap: function() {
        var pins = [
            {
                lat: 48.8530340,
                lon: 2.3865510,
                title: "BOCETO",
                snippet: "Welcome to my office !",
                icon: mapKit.iconColors.HUE_ROSE
            },
            {
                lat: 48.8580340,
                lon: 2.3965510,
                title: "A Cool Title, with no Snippet",
                icon: {
                  type: "asset",
                  resource: "www/img/logo.png", //an image in the asset directory
                  pinColor: mapKit.iconColors.HUE_VIOLET //iOS only
                }
            },
            {
                lat: 48.8630340,
                lon: 2.3765510,
                title: "Awesome Title",
                snippet: "Awesome Snippet",
                icon: mapKit.iconColors.HUE_GREEN
            }
        ];
        var error = function() {
          console.log('error');
        };
        var success = function() {
          mapKit.addMapPins(pins, function() {
                                      console.log('adMapPins success');
                                  },
                                  function() { console.log('error'); });
        };
        mapKit.options = {
            height: window.innerHeight,
            diameter: 1000,
            atBottom: true,
            xPos: window.innerWidth,
            yPos: 0.0,//-window.innerHeight + 200,
            userInteractionEnabled: true,
            lat: 48.8530340,
            lon: 2.3865510
        };

        var directions = [
            {
                srcIsCurrPosition: true,  // Is the source the User's current position ? Else, enter srcLatitude and srcLongitude. Default is false
                srcLatitude: 48.8630340, // Set if srcIsCurrPosition = true
                srcLongitude: 2.3765510, // Set if srcIsCurrPosition = true
                destLatitude: 48.8530340,
                destLongitude: 2.3865510,
                transportTypeWalk: true // Default is car
            }
        ];



        mapKit.showMap(success, error);
        mapKit.showDirections(directions, success, error);


        setTimeout(function(){
            var move = [
                {
                    xPosEnd: 0.0,
                    yPosEnd: 0.0,
                    heightEnd: window.innerHeight,
                    widthEnd: window.innerWidth
                }
            ];
            var btn = [
                {
                    PosX: 10,
                    PosY: 10
                }
            ];
            var shadows = [
                {
                    shadowOffsetX: 0,
                    shadowOffsetY: 0,
                    shadowRadius: 4,
                    shadowOpacity: 0.8,
                    shadowStartX: 0,
                    shadowStartY: -20,
                    shadowHeight: 20,
                    shadowWidth: window.innerWidth
                }
            ];
            var image = [
                {
                    PosX: (window.innerWidth/2) - 38,
                    PosY: 200-38
                }
            ];

            mapKit.addInnerShadows(shadows, success, error);
            mapKit.moveMap(move, success, error);
            //mapKit.addCloseButton(btn, success, error);
            //mapKit.addCoverImage(image, success, error);
        }, 3000);

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
        height: window.innerHeight,
        diameter: 1000,
        atBottom: true,
        xPos: window.innerWidth,
        yPos: 0.0,
        userInteractionEnabled: true,
        lat: 48.8530340,
        lon: 2.3865510
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
