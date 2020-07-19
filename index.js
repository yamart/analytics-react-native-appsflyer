var ReactNative = require('react-native');
var disabled =
  ReactNative.Platform.OS === 'ios'
    ? 'false' === 'true'
    : ReactNative.Platform.OS === 'android'
    ? 'false' === 'true'
    : true;

if (disabled) {
  module.exports = { disabled: true };
} else {
  var bridge = ReactNative.NativeModules['RNAnalyticsIntegration_AppsFlyer'];

  if (!bridge) {
    throw new Error('Failed to load AppsFlyer integration native module');
  }

  var emitter = new ReactNative.NativeEventEmitter(bridge);
  var eventsMap = {};

  module.exports = {
    AppsFlyer: bridge.setup,
    onInstallConversionData: callback => {
      const subscription = emitter.addListener(
        'onInstallConversionData',
        callback
      );

      eventsMap['onInstallConversionData'] = subscription;

      return function remove() {
        subscription.remove();
      };
    },
  };
}
