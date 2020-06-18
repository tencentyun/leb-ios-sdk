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

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.connectRetryCount = 3;
    self.connectRetryInterval = 3;
  }
  return self;
}

-(void)initSDK:(id<LiveEBLogDelegate>)logDelegate minDebugLogLevel:(LiveEBLogLevel)minDebugLogLevel {
    _logDelegate = logDelegate;
    
    NSDictionary *fieldTrials = @{};
    RTCInitFieldTrialDictionary(fieldTrials);
    RTCInitializeSSL();
    RTCSetupInternalTracer();
    
//    #if defined(NDEBUG)
      // In debug builds the default level is LS_INFO and in non-debug builds it is
      // disabled. Continue to log to console in non-debug builds, but only
      // warnings and errors.
      
//    #endif
  
  RTCSetMinDebugLogLevel((RTCLoggingSeverity)minDebugLogLevel);
}

-(void)finitSDK {
    RTCShutdownInternalTracer();
    RTCCleanupSSL();
}
@end



void LiveEBLogEx(LiveEBLogLevel severity, NSString* log_string) {
  RTCLogEx((RTCLoggingSeverity)severity, log_string);
}

NSString* LiveEBLogFileName(const char* file_path) {
  
  return RTCFileName(file_path);
}
