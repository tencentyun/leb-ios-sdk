//
//  AppDelegate.m
//  LiveEB_Demo
//
//  Created by ts on 4/8/20.
//  Copyright © 2020 ts. All rights reserved.
//
#import <LiveEB_IOS/LiveEB_IOS.h>
#import "LiveEBDemoMainViewController.h"
#import "AppDelegate.h"
#include <arpa/inet.h>

@interface AppDelegate () <LiveEBLogDelegate>

@end

@implementation AppDelegate {
  UIWindow *_window;
}


- (void)logWithLevel:(LiveEBLogLevel)logLevel
                 tag:(NSString *)tag
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format
                args:(va_list)args {
    if (logLevel < LiveEBLogLevelInfo) {
        return;
    }
    NSString *logLevelString = nil;
    switch (logLevel) {
        case LiveEBLogLevelDebug:
            logLevelString = @"XBrightLogLevelDebug";
            break;
        case LiveEBLogLevelInfo:
            logLevelString = @"XBrightLogLevelInfo";
            break;
        case LiveEBLogLevelWarning:
            logLevelString = @"XBrightLogLevelWarning";
            break;
        case LiveEBLogLevelError:
            logLevelString = @"XBrightLogLevelError";
            break;
            
        default:
            break;
    }
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    NSLog(@"XBrightLog-[%@][%@]%@",logLevelString, tag, message);
    
}

#pragma mark - UIApplicationDelegate methods

const char* getIPAddress(const char* hostname) {
  Boolean result = FALSE;
  CFHostRef hostRef;
  CFArrayRef addresses;
  char *ip_address = "";
  hostRef = CFHostCreateWithName(kCFAllocatorDefault, CFStringCreateWithCString(NULL, hostname, kCFStringEncodingUTF8));
    if (hostRef) {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL); // pass an error instead of NULL here to find out why it failed
        if (result == TRUE) {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }
    if (result == TRUE) {
        CFIndex index = 0;
        CFDataRef ref = (CFDataRef) CFArrayGetValueAtIndex(addresses, index);
        struct sockaddr_in* remoteAddr;
        
        remoteAddr = (struct sockaddr_in*) CFDataGetBytePtr(ref);
        if (remoteAddr != NULL) {
            ip_address = inet_ntoa(remoteAddr->sin_addr);
        }
    }
    return ip_address;
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
//  char *buffer = malloc(10);
//      buffer[10] = 'A';
//      free(buffer);
  
    __weak typeof(self) weakSelf = self;
//    [[LiveEBManager sharedManager] initSDK:weakSelf minDebugLogLevel:LiveEBLogLevelInfo];
  
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentDirPath = [paths firstObject];
  NSString *defaultDirPath = [documentDirPath stringByAppendingPathComponent:@"lebsdk_logs"];
  [[LiveEBManager sharedManager] initSDK:defaultDirPath maxFileSize:kDefaultMaxFileSize minDebugLogLevel:LiveEBLogLevelInfo];
  [LiveEBManager sharedManager].clientInfo = @"clientinfo_test";
  [LiveEBManager sharedManager].supportAAC = TRUE;
  
  _window =  [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [_window makeKeyAndVisible];
  LiveEBDemoMainViewController *viewController = [[LiveEBDemoMainViewController alloc] init];

  UINavigationController *root =
      [[UINavigationController alloc] initWithRootViewController:viewController];
  root.navigationBar.translucent = NO;
  _window.rootViewController = root;



  return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    [[LiveEBManager sharedManager] finitSDK];
}


//#pragma mark - UISceneSession lifecycle
//
//
//- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
//    // Called when a new scene session is being created.
//    // Use this method to select a configuration to create the new scene with.
//    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
//}
//
//
//- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
//    // Called when the user discards a scene session.
//    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//}


@end
