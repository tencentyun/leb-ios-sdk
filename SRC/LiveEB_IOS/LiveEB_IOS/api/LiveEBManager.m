//
//  LiveEBManager.m
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import "LiveEBManager.h"

#import <WebRTC/RTCFieldTrials.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCSSLAdapter.h>
#import <WebRTC/RTCTracing.h>


#import <WebRTC/RTCAudioSession.h>
#import <WebRTC/RTCAudioSessionConfiguration.h>
#import <WebRTC/RTCDispatcher.h>
#import <WebRTC/RTCLogging.h>

@interface LiveEBManager()

@property (nonatomic, weak) id<LiveEBLogDelegate> logDelegate;
@end

@implementation LiveEBManager

+ (instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static LiveEBManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[LiveEBManager alloc] init];
    });
    return instance;
}



-(void)initSDK:(id<LiveEBLogDelegate>)logDelegate minDebugLogLevel:(LiveEBLogLevel)minDebugLogLevel {
    _logDelegate = logDelegate;
    
    NSDictionary *fieldTrials = @{};
    RTCInitFieldTrialDictionary(fieldTrials);
    RTCInitializeSSL();
    RTCSetupInternalTracer();
    
    #if defined(NDEBUG)
      // In debug builds the default level is LS_INFO and in non-debug builds it is
      // disabled. Continue to log to console in non-debug builds, but only
      // warnings and errors.
      RTCSetMinDebugLogLevel(minDebugLogLevel);
    #endif
}

-(void)finitSDK {
    RTCShutdownInternalTracer();
    RTCCleanupSSL();
}
@end
