//
//  main.m
//  RNAnalyticsIntegration
//
//  Created by fathy on 05/08/2018.
//  Copyright © 2018 Segment.io, Inc. All rights reserved.
//

#import <React/RCTEventEmitter.h>
#import <RNAnalytics/RNAnalytics.h>
#if defined(__has_include) && __has_include(<segment-appsflyer-ios/SEGAppsFlyerIntegrationFactory.h>)
#import <segment-appsflyer-ios/SEGAppsFlyerIntegrationFactory.h>
#else
#import <segment-appsflyer-ios/SEGAppsFlyerIntegrationFactory.h>
#endif

@interface RNAnalyticsIntegration_AppsFlyer: RCTEventEmitter<RCTBridgeModule, SEGAppsFlyerTrackerDelegate>
@end

@implementation RNAnalyticsIntegration_AppsFlyer

RCT_EXPORT_MODULE()

RCT_REMAP_METHOD(setup,
                setupWithResolver:(RCTPromiseResolveBlock)resolve
                rejecter:(RCTPromiseRejectBlock)reject)
{
    NSLog(@"RNAnalyticsIntegration_AppsFlyer setup");
    [RNAnalytics addIntegration:SEGAppsFlyerIntegrationFactory.instance];
    SEGAppsFlyerIntegrationFactory.instance.delegate = self;
    resolve(@{});
}

- (NSArray<NSString *> *)supportedEvents
{
  return @[@"onInstallConversionData"];
}

- (void)onConversionDataReceived:(NSDictionary *)installData{
    NSDictionary* message = @{
                                   @"status": @"success",
                                   @"type": @"onConversionDataReceived",
                                   @"data": installData
                                 };

    [self performSelectorOnMainThread:@selector(handleCallback:) withObject:message waitUntilDone:NO];
};

- (void) onAppOpenAttribution:(NSDictionary*) attributionData
{
    NSDictionary* message = @{
                                   @"status": @"success",
                                   @"type": @"onAppOpenAttribution",
                                   @"data": attributionData
                                 };

    [self performSelectorOnMainThread:@selector(handleCallback:) withObject:message waitUntilDone:NO];
}

- (void) onAppOpenAttributionFailure:(NSError *)error
{
    NSDictionary* errorMessage = @{
                                   @"status": @"failure",
                                   @"type": @"onAppOpenAttributionFailure",
                                   @"data": error
                                 };

    [self performSelectorOnMainThread:@selector(handleCallback:) withObject:errorMessage waitUntilDone:NO];
}

-(void) handleCallback:(NSDictionary *) message {
    NSError *error;

    if ([NSJSONSerialization isValidJSONObject:message]) {
        NSData *jsonMessage = [NSJSONSerialization dataWithJSONObject:message
                                                              options:0
                                                                error:&error];
        if (jsonMessage) {
            NSString *jsonMessageStr = [[NSString alloc] initWithBytes:[jsonMessage bytes] length:[jsonMessage length] encoding:NSUTF8StringEncoding];
            NSString* status = (NSString*)[message objectForKey: @"status"];
            
            if ([status isEqualToString:@"success"]) {
                [self reportOnSuccess:jsonMessageStr];
            } else {
                [self reportOnFailure:jsonMessageStr];
            }
            
            NSLog(@"jsonMessageStr = %@", jsonMessageStr);
        } else {
            NSLog(@"%@", error);
        }
    } else {
       [self reportOnFailure:@"failed to parse response"];
    }
}

-(void) reportOnFailure:(NSString *) errorMessage {
  NSLog(@"RNAnalyticsIntegration_AppsFlyer reportOnFailure %@", errorMessage);
  [self sendEventWithName:@"onInstallConversionData" body:errorMessage];
}

-(void) reportOnSuccess:(NSString *) data {
  NSLog(@"RNAnalyticsIntegration_AppsFlyer reportOnSuccess %@", data);
  [self sendEventWithName:@"onInstallConversionData" body:data];
}

@end
