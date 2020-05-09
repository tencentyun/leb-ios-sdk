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

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    __weak typeof(self) weakSelf = self;
    [[LiveEBManager sharedManager] initSDK:weakSelf minDebugLogLevel:LiveEBLogLevelDebug];
    [LiveEBManager sharedManager].clientInfo = @"clientinfo_test";
    
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
