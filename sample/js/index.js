/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicity call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
        app.showMap();
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);

    },
    showMap: function() {
        var pins = [
            {
                lat: 48.8530340,
                lon: 2.3865510,
                title: "BOCETO",
                snippet: "Bienvenue au bureau !",
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
                destLatitude: 48.8630340,
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
          document.getElementById('hide_map').style.display = 'none';
          document.getElementById('clear_map_pins').style.display = 'none';
          document.getElementById('show_map').style.display = 'block';
        };
        var error = function() {
          console.log('error');
        };
        mapKit.hideMap(success, error);
    },
    clearMapPins: function() {
        var success = function() {
          console.log('Map Pins cleared!');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.clearMapPins(success, error);
    },
    changeMapType: function() {
      var success = function() {
          console.log('Map Type Changed');
        };
        var error = function() {
          console.log('error');
        };
        mapKit.changeMapType(mapKit.mapType.MAP_TYPE_SATELLITE, success, error);
    }
};


