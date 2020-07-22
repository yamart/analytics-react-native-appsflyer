var { Platform, NativeModules, NativeEventEmitter } = require('react-native');
var eventsMap = {};

class AppsFlyerBridge {
	bridge;
	emitter;

	constructor() {
		if (!this.isDisabled()) {
			this.init();
		}
	}

	isDisabled() {
		return Platform.OS === 'ios' ? 'false' === 'true' : Platform.OS === 'android' ? 'false' === 'true' : true;
	}

	init() {
		const bridge = NativeModules['RNAnalyticsIntegration_AppsFlyer'];

		if (!bridge) {
			throw new Error('Failed to load AppsFlyer integration native module');
		}

		this.bridge = bridge;
		this.emitter = new NativeEventEmitter(bridge);
	}

	setup = async () => {
		try {
			if (!this.isDisabled() && this.bridge) {
				return await this.bridge.setup();
			}
		} catch (e) {
			console.log(e);
		}

		return { disabled: true };
	};

	onConversionDataReceived = (callback) => {
		if (this.isDisabled()) {
			return () => {};
		}

		const subscription = this.emitter.addListener('onConversionDataReceived', callback);
		eventsMap['onConversionDataReceived'] = subscription;

		return () => {
			subscription.remove();
		};
	};
}

module.exports = new AppsFlyerBridge();
