package com.phonegap.plugins.mapkit;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.util.TypedValue;
import android.view.View;
import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;
import android.app.Dialog;
import android.content.DialogInterface;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.google.android.gms.maps.model.BitmapDescriptor;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.VisibleRegion;

public class MapKit extends CordovaPlugin {

    protected ViewGroup root; // original Cordova layout
    protected RelativeLayout main; // new layout to support map
    protected MapView mapView;
    private CallbackContext cCtx;
    private String TAG = "MapKitPlugin";
    private Marker lastClicked;

    double latitude = 0, longitude = 0;
    int height = 460;
    boolean atBottom = false;
    int offsetTop = 0;
    int zoomLevel = 0;
    boolean infoWindowOpen = false;

    @Override
    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        main = new RelativeLayout(cordova.getActivity());
    }

    public void showMap(final JSONObject options) {
        try {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                	if (mapView != null) {
                		mapView.setVisibility(mapView.VISIBLE);
                	} else {
                        LOG.e(TAG, "hello world");
                        LOG.e(TAG, options);
                        try {
                            height = options.getInt("height");
                            latitude = options.getDouble("lat");
                            longitude = options.getDouble("lon");
                            offsetTop = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, options.getInt("offsetTop"), cordova.getActivity().getResources().getDisplayMetrics());
    						zoomLevel = options.getInt("zoomLevel");
                            atBottom = options.getBoolean("atBottom");
                            LOG.e(height);
                        } catch (JSONException e) {
                            LOG.e(TAG, "Error reading options");
                        }

                        final int resultCode = GooglePlayServicesUtil.isGooglePlayServicesAvailable(cordova.getActivity());
                        if (resultCode == ConnectionResult.SUCCESS) {
                            mapView = new MapView(cordova.getActivity(),
                                    new GoogleMapOptions());
                            root = (ViewGroup) webView.getParent();
                            root.removeView(webView);
                            main.addView(webView);

                            cordova.getActivity().setContentView(main);

                            MapsInitializer.initialize(cordova.getActivity());

                            RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                                    LayoutParams.MATCH_PARENT, height);
                            if (atBottom) {
                                params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM,
                                        RelativeLayout.TRUE);
                                mapView.setPadding(0, offsetTop, 0, 0);
                            } else {
                                params.addRule(RelativeLayout.ALIGN_PARENT_TOP,
                                        RelativeLayout.TRUE);
                                mapView.setPadding(0, offsetTop, 0, 0);
                            }
                            params.addRule(RelativeLayout.CENTER_HORIZONTAL,
                                    RelativeLayout.TRUE);

                            mapView.setLayoutParams(params);
                            mapView.onCreate(null);
                            mapView.onResume(); // FIXME: I wish there was a better way
                                                // than this...
                            main.addView(mapView);
                            
                            mapView.getMap().setMyLocationEnabled(true);
							mapView.getMap().getUiSettings().setMyLocationButtonEnabled(false);

                            // Moving the map to lot, lon
                            mapView.getMap().moveCamera(
                                    CameraUpdateFactory.newLatLngZoom(new LatLng(
                                            latitude, longitude), 15));
                            cCtx.success();
                            
                            mapView.getMap().setOnMarkerClickListener(new GoogleMap.OnMarkerClickListener() {
								@Override
						        public boolean onMarkerClick(final Marker marker) {
									webView.loadUrl(
											"javascript:annotationTap('" + 
													marker.getSnippet() + 
											"'.toString(), " + 
													marker.getPosition().latitude + 
											", " + 
													marker.getPosition().longitude + 
											");");
							        
							        //set variable so we can close it later
							        lastClicked = marker;
//									Log.d("MYTAG", "on Marker click: " + marker.getSnippet());
//									Log.d("MYTAG", "on Marker click: " +  marker.getPosition().latitude);
//									Log.d("MYTAG", "on Marker click: " +  marker.getPosition().longitude);
						            return false;
						        }
                            });
                            
                            mapView.getMap().setOnCameraChangeListener(new GoogleMap.OnCameraChangeListener() {
								@Override
						        public void onCameraChange(CameraPosition position) {
									VisibleRegion vr = mapView.getMap().getProjection().getVisibleRegion();
									double left = vr.latLngBounds.southwest.longitude;
									double top = vr.latLngBounds.northeast.latitude;
									double right = vr.latLngBounds.northeast.longitude;
									double bottom = vr.latLngBounds.southwest.latitude;
									double longDelta = left - right;
									double latDelta = top - bottom;
									
									webView.loadUrl(
											"javascript:geo.onMapMove(" +
												position.target.latitude + 
											"," + 
												position.target.longitude + 
											"," + 
												latDelta +
											"," +
												longDelta +
											");");
//									Log.d("MYTAG", "on Marker click: " + marker.getSnippet());
//									Log.d("MYTAG", "on Marker click: " +  marker.getPosition().latitude);
//									Log.d("MYTAG", "on Marker click: " +  marker.getPosition().longitude);
						            return;
						        }
							});
                            
                            // set variables when infoWindows open, so we can tell when they close
							mapView.getMap().setInfoWindowAdapter(new GoogleMap.InfoWindowAdapter() {
								@Override
								public View getInfoWindow(final Marker marker) {
//									Log.d("MYTAG", "on infowindow: " + marker);
									if (infoWindowOpen == false) {
										infoWindowOpen = true;
									}

									return null;
						        }

								@Override
								public View getInfoContents(Marker marker) {
									return null;
								}
							});
							
							// when the map is clicked (not a pin or an infowindow), 
							// find out if we just closed an infowindow and if so, call a javascript function
							mapView.getMap().setOnMapClickListener(new GoogleMap.OnMapClickListener() {
								@Override
						        public void onMapClick(final LatLng latlng) {
									
									if (infoWindowOpen == true) {
										//Log.d("MYTAG", "on infowindow close: " + latlng.latitude);
										infoWindowOpen = false;
										webView.loadUrl("javascript:annotationDeselect();");
									}
						        }
							});

                        } else if (resultCode == ConnectionResult.SERVICE_MISSING ||
                                   resultCode == ConnectionResult.SERVICE_VERSION_UPDATE_REQUIRED ||
                                   resultCode == ConnectionResult.SERVICE_DISABLED) {
                            Dialog dialog = GooglePlayServicesUtil.getErrorDialog(resultCode, cordova.getActivity(), 1,
                                        new DialogInterface.OnCancelListener() {
                                            @Override
                                            public void onCancel(DialogInterface dialog) {
                                                cCtx.error("com.google.android.gms.common.ConnectionResult " + resultCode);
                                            }
                                        }
                                    );
                            dialog.show();
                        }
                	}
                    

                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            cCtx.error("MapKitPlugin::showMap(): An exception occured");
        }
    }
    
    public void setMapData(final JSONObject options) {
		//Log.d("MYTAG", "setMapData");
		try {
			cordova.getActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
					try {
						height = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,options.getInt("height"), cordova.getActivity().getResources().getDisplayMetrics());
						latitude = options.getDouble("lat");
						longitude = options.getDouble("lon");
						offsetTop = (int) TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP,options.getInt("offsetTop"), cordova.getActivity().getResources().getDisplayMetrics());
						zoomLevel = options.getInt("zoomLevel");
						atBottom = options.getBoolean("atBottom");
					} catch (JSONException e) {
						LOG.e(TAG, "Error reading options");
					}

					RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
							LayoutParams.MATCH_PARENT, height + offsetTop);
					if (atBottom) {
						params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM,
								RelativeLayout.TRUE);
						mapView.setPadding(0, offsetTop, 0, 0);
					} else {
						params.addRule(RelativeLayout.ALIGN_PARENT_TOP,
								RelativeLayout.TRUE);
						mapView.setPadding(0, offsetTop, 0, 0);
					}
					params.addRule(RelativeLayout.CENTER_HORIZONTAL,
							RelativeLayout.TRUE);

					mapView.setLayoutParams(params);

					mapView.getMap().animateCamera(
							CameraUpdateFactory.newLatLngZoom(new LatLng(
									latitude, longitude), zoomLevel));
					cCtx.success();
				}
			});
		} catch (Exception e) {
			e.printStackTrace();
			cCtx.error("MapKitPlugin::showMap(): An exception occured");
		}
    }

    private void hideMap() {
        try {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    String hideMethod = "";
                	// if we're not destroying the map, then just hide it...
					if (mapView != null && !hideMethod.equals("destroy")) {
						//Log.d("MYTAG", "true");
//						AlphaAnimation animation2 = new AlphaAnimation(1.0f, 0.0f);
//						animation2.setDuration(1000);
//						mapView.startAnimation(animation2);
						lastClicked.hideInfoWindow();
						mapView.setVisibility(mapView.GONE);
						cCtx.success();
					} else {
						//Log.d("MYTAG", "false");
						mapView.onDestroy();
						main.removeView(webView);
						main.removeView(mapView);
						root.addView(webView);
						cordova.getActivity().setContentView(root);
						mapView = null;
						cCtx.success();
					}
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            cCtx.error("MapKitPlugin::hideMap(): An exception occured");
        }
    }

    public void addMapPins(final JSONArray pins) {
        try {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (mapView != null) {
                        try {
                            for (int i = 0, j = pins.length(); i < j; i++) {
                                double latitude = 0, longitude = 0;
                                
                                JSONObject options = pins.getJSONObject(i);
                                latitude = options.getDouble("lat");
                                longitude = options.getDouble("lon");

                                MarkerOptions mOptions = new MarkerOptions();

                                mOptions.position(new LatLng(latitude,
                                                             longitude));
                                if(options.has("title")) {
                                    mOptions.title(options.getString("title"));
                                }
                                if(options.has("snippet")) {
                                    mOptions.snippet(options.getString("snippet"));
                                }
                                if(options.has("icon")) {
                                    BitmapDescriptor bDesc = getBitmapDescriptor(options);
                                    if(bDesc != null) {
                                      mOptions.icon(bDesc);
                                    }
                                }

                                // adding Marker
                                // This is to prevent non existing asset resources to crash the app
                                try {
                                    mapView.getMap().addMarker(mOptions);
                                } catch(NullPointerException e) {
                                    LOG.e(TAG, "An error occurred when adding the marker. Check if icon exists");
                                }
                            }
                            cCtx.success();
                        } catch (JSONException e) {
                            e.printStackTrace();
                            LOG.e(TAG, "An error occurred while reading pins");
                            cCtx.error("An error occurred while reading pins");
                        }
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            cCtx.error("MapKitPlugin::addMapPins(): An exception occured");
        }
    }

    private BitmapDescriptor getBitmapDescriptor( final JSONObject iconOption ) {
        try {
            Object o = iconOption.get("icon");
            String type = null, resource = null;
            if( o.getClass().getName().equals("org.json.JSONObject" ) ) {
                JSONObject icon = (JSONObject)o;
                if(icon.has("type") && icon.has("resource")) {
                    type = icon.getString("type");
                    resource = icon.getString("resource");
                    if(type.equals("asset")) {
                        return BitmapDescriptorFactory.fromAsset(resource);
                    }
                }
            } else {
                //this is a simple change in the icon's color
                return BitmapDescriptorFactory.defaultMarker(Float.parseFloat(o.toString()));
            }
        } catch (JSONException e){
            e.printStackTrace();
        }
        return null;
    }

    public void clearMapPins() {
        try {
            cordova.getActivity().runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (mapView != null) {
                        mapView.getMap().clear();
                        cCtx.success();
                    }
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            cCtx.error("MapKitPlugin::clearMapPins(): An exception occured");
        }
    }

    public void changeMapType(final JSONObject options) {
        try{
            cordova.getActivity().runOnUiThread(new Runnable() {

                @Override
                public void run() {
                    if( mapView != null ) {
                        int mapType = 0;
                        try {
                            mapType = options.getInt("mapType");
                        } catch (JSONException e) {
                            LOG.e(TAG, "Error reading options");
                        }

                        //Don't want to set the map type if it's the same
                        if(mapView.getMap().getMapType() != mapType) {
                            mapView.getMap().setMapType(mapType);
                        }
                    }

                    cCtx.success();
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
            cCtx.error("MapKitPlugin::changeMapType(): An exception occured ");
        }
    }

    public boolean execute(String action, JSONArray args,
            CallbackContext callbackContext) throws JSONException {
        cCtx = callbackContext;
        if (action.compareTo("showMap") == 0) {
            showMap(args.getJSONObject(0));
        } else if (action.compareTo("hideMap") == 0) {
            hideMap();
        } else if (action.compareTo("addMapPins") == 0) {
            addMapPins(args.getJSONArray(0));
        } else if (action.compareTo("clearMapPins") == 0) {
            clearMapPins();
        } else if( action.compareTo("changeMapType") == 0 ) {
            changeMapType(args.getJSONObject(0));
        }
        LOG.d(TAG, action);

        return true;
    }

    @Override
    public void onPause(boolean multitasking) {
        LOG.d(TAG, "MapKitPlugin::onPause()");
        if (mapView != null) {
            mapView.onPause();
        }
        super.onPause(multitasking);
    }

    @Override
    public void onResume(boolean multitasking) {
        LOG.d(TAG, "MapKitPlugin::onResume()");
        if (mapView != null) {
            mapView.onResume();
        }
        super.onResume(multitasking);
    }

    @Override
    public void onDestroy() {
        LOG.d(TAG, "MapKitPlugin::onDestroy()");
        if (mapView != null) {
            mapView.onDestroy();
        }
        super.onDestroy();
    }
}
