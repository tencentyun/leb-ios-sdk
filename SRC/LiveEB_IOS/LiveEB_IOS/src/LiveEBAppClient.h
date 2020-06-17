/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>
#import <WebRTC/RTCPeerConnection.h>
#import <WebRTC/WebRTC.h>

typedef NS_ENUM(NSInteger, ARDAppClientState) {
  // Disconnected from servers.
  kARDAppClientStateDisconnected,
  // Connecting to servers.
  kARDAppClientStateConnecting,
  // Connected to servers.
  kARDAppClientStateConnected,
};

@class LiveEBAppClient;
@class ARDSettingsModel;
@class ARDExternalSampleCapturer;
@class RTCMediaConstraints;
@class RTCCameraVideoCapturer;
@class RTCFileVideoCapturer;

// The delegate is informed of pertinent events and will be called on the
// main queue.
@protocol LiveEBAppClientDelegate <NSObject>

- (void)appClient:(LiveEBAppClient *)client didChangeState:(ARDAppClientState)state;

- (void)appClient:(LiveEBAppClient *)client didChangeConnectionState:(RTCIceConnectionState)state;

- (void)appClient:(LiveEBAppClient *)client didReceiveLocalVideoTrack:(RTCVideoTrack *)localVideoTrack;

- (void)appClient:(LiveEBAppClient *)client
    didReceiveRemoteVideoTrack:(RTCVideoTrack *)remoteVideoTrack;

- (void)appClient:(LiveEBAppClient *)client
didReceiveRemoteAudioTrack:(RTCAudioTrack *)remoteAudioTrack;

- (void)appClient:(LiveEBAppClient *)client didError:(NSError *)error;

- (void)appClient:(LiveEBAppClient *)client didGetStats:(NSArray *)stats;



- (void)appClient:(LiveEBAppClient *)client
    didCreateLocalExternalSampleCapturer:(ARDExternalSampleCapturer *)externalSampleCapturer;

@end

// Handles connections to the AppRTC server for a given room. Methods on this
// class should only be called from the main queue.
@interface LiveEBAppClient : NSObject

// If |shouldGetStats| is true, stats will be reported in 1s intervals through
// the delegate.
@property(nonatomic, assign) BOOL shouldGetStats;
@property(nonatomic, readonly) ARDAppClientState state;
@property(nonatomic, weak) id<LiveEBAppClientDelegate> delegate;
@property(nonatomic, assign, getter=isBroadcast) BOOL broadcast;


@property (nonatomic, copy) NSString *rtcHost;
@property (nonatomic, copy) NSString *liveEBURL; //播放流地址 webrtc://
@property (nonatomic, copy) NSString *sessionid; //业务生成的唯一key，标识本次播放会话
@property (nonatomic, copy) NSString *clientInfo;

// Convenience constructor since all expected use cases will need a delegate
// in order to receive remote tracks.
- (instancetype)initWithDelegate:(id<LiveEBAppClientDelegate>)delegate;

// Establishes a connection with the AppRTC servers for the given room id.
// |settings| is an object containing settings such as video codec for the call.
// If |isLoopback| is true, the call will connect to itself.
- (void)initWithSettings:(ARDSettingsModel *)settings
                 isLoopback:(BOOL)isLoopback;

// Disconnects from the AppRTC servers and any connected clients.
- (void)disconnect;

-(void)useLiveBroadcasting:(NSString*)streamurl;

-(void)stopStream;

-(void)connectLiveBroadcast;

@end
