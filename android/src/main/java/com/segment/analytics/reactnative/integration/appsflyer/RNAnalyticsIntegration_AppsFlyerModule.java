package com.segment.analytics.reactnative.integration.appsflyer;

import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.segment.analytics.reactnative.core.RNAnalytics;
import com.segment.analytics.android.integrations.appsflyer.AppsflyerIntegration;
import com.facebook.react.modules.core.DeviceEventManagerModule.RCTDeviceEventEmitter;

import java.util.Map;

public class RNAnalyticsIntegration_AppsFlyerModule extends ReactContextBaseJavaModule {

  private final ReactApplicationContext reactContext;

  public RNAnalyticsIntegration_AppsFlyerModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
    this.initConversionListener();
  }

  @Override
  public String getName() {
    return "RNAnalyticsIntegration_AppsFlyer";
  }

  @ReactMethod
  public void setup() {
    RNAnalytics.INSTANCE.addIntegration(AppsflyerIntegration.FACTORY);
  }

  private void initConversionListener() {
    final RNAnalyticsIntegration_AppsFlyerModule self = this;

    AppsflyerIntegration.cld = new AppsflyerIntegration.ConversionListenerDisplay() {
      @Override
      public void display(Map<String, String> attributionData) {
        self.reactContext.getJSModule(RCTDeviceEventEmitter.class).emit("onConversionDataReceived", attributionData.toString());
      }
    };
  }
}
