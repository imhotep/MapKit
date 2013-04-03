package com.phonegap.plugins.mapkit;

import org.apache.cordova.CordovaWebView;
import org.apache.cordova.api.CallbackContext;
import org.apache.cordova.api.CordovaInterface;
import org.apache.cordova.api.CordovaPlugin;
import org.apache.cordova.api.LOG;
import org.json.JSONArray;
import org.json.JSONException;

import android.view.ViewGroup;
import android.widget.RelativeLayout;
import android.widget.RelativeLayout.LayoutParams;

import com.google.android.gms.common.GooglePlayServicesNotAvailableException;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.MapView;
import com.google.android.gms.maps.MapsInitializer;

public class MapKit extends CordovaPlugin {

	protected ViewGroup root; // original Cordova layout
	protected RelativeLayout main; // new layout to support map
	protected MapView mapView;
	private CallbackContext cCtx;
	private String TAG = "MapKitPlugin";

	@Override
	public void initialize(CordovaInterface cordova, CordovaWebView webView) {
		super.initialize(cordova, webView);
		main = new RelativeLayout(cordova
				.getActivity());
		mapView = new MapView(cordova.getActivity(), new GoogleMapOptions());
	}

	public void showMap() {
		try {
			cordova.getActivity().runOnUiThread(new Runnable() {
				@Override
				public void run() {
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
							LayoutParams.MATCH_PARENT, 400);
					params.addRule(RelativeLayout.ALIGN_PARENT_TOP,
							RelativeLayout.TRUE);
					params.addRule(RelativeLayout.CENTER_HORIZONTAL,
							RelativeLayout.TRUE);

					mapView.setLayoutParams(params);
					mapView.onCreate(null);
					mapView.onResume(); // FIXME: I wish there was a better way than this...
					main.addView(mapView);
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
					mapView.onDestroy();
					main.removeView(webView);
					main.removeView(mapView);
					root.addView(webView);
					cordova.getActivity().setContentView(root);
					cCtx.success();

				}
			});
		} catch (Exception e) {
			e.printStackTrace();
			cCtx.error("MapKitPlugin::hideMap(): An exception occured");
		}
	}

	public boolean execute(String action, JSONArray args,
			CallbackContext callbackContext) throws JSONException {
		cCtx = callbackContext;
		if(action.compareTo("showMap") == 0) {
			showMap();
		} else if(action.compareTo("hideMap") == 0) {
			hideMap();
		} else if(action.compareTo("setMapData") == 0) {
			// TODO
		} else if(action.compareTo("addMapPins") == 0) {
			// TODO
		} else if(action.compareTo("clearMapPins") == 0) {
			
		}
		LOG.d(TAG, action);

		return true;
	}

	@Override
	public void onPause(boolean multitasking) {
		LOG.d(TAG, "MapKitPlugin::onPause()");
		super.onPause(multitasking);
		mapView.onPause();
	}

	@Override
	public void onResume(boolean multitasking) {
		LOG.d(TAG, "MapKitPlugin::onResume()");
		super.onResume(multitasking);
		mapView.onResume();
	}

	@Override
	public void onDestroy() {
		LOG.d(TAG, "MapKitPlugin::onDestroy()");
		super.onDestroy();
		mapView.onDestroy();
	}
}