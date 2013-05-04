package com.phonegap.plugins.mapkit;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaInterface;
import org.apache.cordova.api.CordovaPlugin;
import org.apache.cordova.api.LOG;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;

import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.MarkerOptions;

public class MapKit extends CordovaPlugin {

	protected ViewGroup root; // original Cordova layout
	protected RelativeLayout main; // new layout to support map
	protected MapView mapView;
	private CallbackContext cCtx;
	private String TAG = "MapKitPlugin";

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
					double latitude = 0, longitude = 0;
					int height = 460;
					boolean atBottom = false;
					try {
						height = options.getInt("height");
						latitude = options.getDouble("lat");
						longitude = options.getDouble("lon");
						atBottom = options.getBoolean("atBottom");
					} catch (JSONException e) {
						LOG.e(TAG, "Error reading options");
					}
					mapView = new MapView(cordova.getActivity(),
							new GoogleMapOptions());
					root = (ViewGroup) webView.getParent();
					root.removeView(webView);
					main.addView(webView);

					cordova.getActivity().setContentView(main);

					try {
						MapsInitializer.initialize(cordova.getActivity());
					} catch (GooglePlayServicesNotAvailableException e) {
						e.printStackTrace();
					}

					RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
							LayoutParams.MATCH_PARENT, height);
					if (atBottom) {
						params.addRule(RelativeLayout.ALIGN_PARENT_BOTTOM,
								RelativeLayout.TRUE);
					} else {
						params.addRule(RelativeLayout.ALIGN_PARENT_TOP,
								RelativeLayout.TRUE);
					}
					params.addRule(RelativeLayout.CENTER_HORIZONTAL,
							RelativeLayout.TRUE);

					mapView.setLayoutParams(params);
					mapView.onCreate(null);
					mapView.onResume(); // FIXME: I wish there was a better way
										// than this...
					main.addView(mapView);

					// Moving the map to lot, lon
					mapView.getMap().moveCamera(
							CameraUpdateFactory.newLatLngZoom(new LatLng(
									latitude, longitude), 15));
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
					if (mapView != null) {
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
                                String title = null, snippet = null;
                                JSONObject options = pins.getJSONObject(i);
                                latitude = options.getDouble("lat");
                                longitude = options.getDouble("lon");
                                if(options.has("title")) {
                                    title = options.getString("title");
                                }
                                if( options.has("snippet") ) {
                                    snippet = options.getString("snippet");
                                }
                                // adding Marker
                                mapView.getMap().addMarker(
                                        new MarkerOptions()
                                                .title(title)
                                                .snippet(snippet) //If there is no title,  the snippet isn't displayed
                                                .position(new LatLng(latitude,
                                                        longitude)));
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