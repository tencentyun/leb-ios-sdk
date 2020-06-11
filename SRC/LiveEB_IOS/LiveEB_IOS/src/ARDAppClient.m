/*
 *  Copyright 2014 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-variable"

#import "ARDAppClient+Internal.h"

#import <WebRTC/RTCAudioTrack.h>
#import <WebRTC/RTCCameraVideoCapturer.h>
#import <WebRTC/RTCConfiguration.h>
#import <WebRTC/RTCDefaultVideoDecoderFactory.h>
#import <WebRTC/RTCDefaultVideoEncoderFactory.h>
#import <WebRTC/RTCFileLogger.h>
#import <WebRTC/RTCFileVideoCapturer.h>
#import <WebRTC/RTCIceServer.h>
#import <WebRTC/RTCLogging.h>
#import <WebRTC/RTCMediaConstraints.h>
#import <WebRTC/RTCMediaStream.h>
#import <WebRTC/RTCPeerConnectionFactory.h>
#import <WebRTC/RTCRtpSender.h>
#import <WebRTC/RTCRtpTransceiver.h>
#import <WebRTC/RTCTracing.h>
#import <WebRTC/RTCVideoSource.h>
#import <WebRTC/RTCVideoTrack.h>

#import "ARDAppEngineClient.h"
#import "ARDExternalSampleCapturer.h"
#import "ARDJoinResponse.h"
#import "ARDMessageResponse.h"
#import "ARDSettingsModel.h"
#import "ARDSignalingMessage.h"
#import "ARDTURNClient+Internal.h"
#import "ARDUtilities.h"
#import "ARDWebSocketChannel.h"
#import "RTCIceCandidate+JSON.h"
#import "RTCSessionDescription+JSON.h"

//#import "ARDSDPUtils.h"ff
#import <objc/runtime.h>



@interface RTCDefaultVideoEncoderFactory (BugFix)

+ (void)load;
//- (NSArray<RTCVideoCodecInfo *> *)supportedCodecs;

@end


@implementation RTCDefaultVideoEncoderFactory (BugFix)

+(void)load
{
    Class cls = [self class];
    
    SEL originalSelector = NSSelectorFromString(@"supportedCodecs");
    SEL swizzledSelector = NSSelectorFromString(@"supportedCodecsReplace");
    
    NSLog(@"RTCDefaultVideoEncoderFactory cls=%p %p %p", cls, originalSelector, swizzledSelector);
    
    Method originalMethod = class_getInstanceMethod(cls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
    BOOL didAddMethod = class_addMethod(cls, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }else{
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
    
    
}


- (NSArray<RTCVideoCodecInfo *> *)supportedCodecsReplace{
    if (self.preferredCodec != NULL) {
        NSMutableArray<RTCVideoCodecInfo *> *codecs = [[[self class] supportedCodecs] mutableCopy];

        NSMutableArray<RTCVideoCodecInfo *> *orderedCodecs = [NSMutableArray array];
        NSUInteger index = [codecs indexOfObject:self.preferredCodec];
          
          NSLog(@"supportedCodecsReplace defaultVideoCodecSetting=%@ %@ index=%lu", self.preferredCodec.name, self.preferredCodec.parameters, index);
          
        if (index == NSNotFound) {
            index = 0;
          [orderedCodecs addObject:[codecs objectAtIndex:index]];
          [codecs removeObjectAtIndex:index];
        }
        [orderedCodecs addObject:self.preferredCodec];

        return [orderedCodecs copy];
    } else {
        return [self supportedCodecsReplace];
    }
  
}

@end


static NSString * const kARDAppClientErrorDomain = @"ARDAppClient";
static NSInteger const kARDAppClientErrorUnknown = -1;
static NSInteger const kARDAppClientErrorRoomFull = -2;
static NSInteger const kARDAppClientErrorCreateSDP = -3;
static NSInteger const kARDAppClientErrorSetSDP = -4;
static NSInteger const kARDAppClientErrorInvalidClient = -5;
static NSInteger const kARDAppClientErrorInvalidRoom = -6;
static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";

// TODO(tkchin): Add these as UI options.
#if defined(WEBRTC_IOS)
static BOOL const kARDAppClientEnableTracing = NO;
static BOOL const kARDAppClientEnableRtcEventLog = YES;
static int64_t const kARDAppClientAecDumpMaxSizeInBytes = 5e6;  // 5 MB.
static int64_t const kARDAppClientRtcEventLogMaxSizeInBytes = 5e6;  // 5 MB.
#endif
static int const kKbpsMultiplier = 1000;

// We need a proxy to NSTimer because it causes a strong retain cycle. When
// using the proxy, |invalidate| must be called before it properly deallocs.
@interface ARDTimerProxy : NSObject

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    timerHandler:(void (^)(void))timerHandler;
- (void)invalidate;

@end

@implementation ARDTimerProxy {
  NSTimer *_timer;
  void (^_timerHandler)(void);
}

- (instancetype)initWithInterval:(NSTimeInterval)interval
                         repeats:(BOOL)repeats
                    timerHandler:(void (^)(void))timerHandler {
  NSParameterAssert(timerHandler);
  if (self = [super init]) {
    _timerHandler = timerHandler;
    _timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                              target:self
                                            selector:@selector(timerDidFire:)
                                            userInfo:nil
                                             repeats:repeats];
  }
  return self;
}

- (void)invalidate {
  [_timer invalidate];
}

- (void)timerDidFire:(NSTimer *)timer {
  _timerHandler();
}

@end

@interface ARDAppClient()
{
BOOL _useLiveEventBroadcasting;
NSString *_liveBroadcastingStreamUrl;
NSString *_svrsig;
}
@end

@implementation ARDAppClient {
  RTCFileLogger *_fileLogger;
  ARDTimerProxy *_statsTimer;
  ARDSettingsModel *_settings;
  RTCVideoTrack *_localVideoTrack;
}

@synthesize shouldGetStats = _shouldGetStats;
@synthesize state = _state;
@synthesize delegate = _delegate;
@synthesize roomServerClient = _roomServerClient;
@synthesize channel = _channel;
@synthesize loopbackChannel = _loopbackChannel;
@synthesize turnClient = _turnClient;
@synthesize peerConnection = _peerConnection;
@synthesize factory = _factory;
@synthesize messageQueue = _messageQueue;
@synthesize isTurnComplete = _isTurnComplete;
@synthesize hasReceivedSdp  = _hasReceivedSdp;
@synthesize roomId = _roomId;
@synthesize clientId = _clientId;
@synthesize isInitiator = _isInitiator;
@synthesize iceServers = _iceServers;
@synthesize webSocketURL = _websocketURL;
@synthesize webSocketRestURL = _websocketRestURL;
@synthesize defaultPeerConnectionConstraints =
    _defaultPeerConnectionConstraints;
@synthesize isLoopback = _isLoopback;
@synthesize broadcast = _broadcast;

- (instancetype)init {
  return [self initWithDelegate:nil];
}

- (instancetype)initWithDelegate:(id<ARDAppClientDelegate>)delegate {
  if (self = [super init]) {
    _useLiveEventBroadcasting = FALSE;
      _liveBroadcastingStreamUrl = nil;
    _roomServerClient = [[ARDAppEngineClient alloc] init];
    _delegate = delegate;
      
    [self configure];
  }
  return self;
}

- (void)useLiveBroadcasting:(NSString *)streamurl {
    _useLiveEventBroadcasting = TRUE;
    
    _liveBroadcastingStreamUrl = streamurl;
}

+ (RTCSessionDescription *)descriptionFromJSONDictionary:
    (NSDictionary *)dictionary {
  NSString *typeString = dictionary[@"type"];
  RTCSdpType type = [[RTCSessionDescription class] typeForString:typeString];
  NSString *sdp = dictionary[@"sdp"];
  return [[RTCSessionDescription alloc] initWithType:type sdp:sdp];
}

+ (void)sendAsyncRequest:(NSURLRequest *)request
       completionHandler:(void (^)(NSURLResponse *response,
                                   NSData *data,
                                   NSError *error))completionHandler {
  // Kick off an async request which will call back on main thread.
  NSURLSession *session = [NSURLSession sharedSession];
  [[session dataTaskWithRequest:request
              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                if (completionHandler) {
                  completionHandler(response, data, error);
                }
              }] resume];
}

-(void)stopStream {
    
    NSString *rtcUrl = NULL;
    bool ismyqcloud = false;
    NSString *host= NULL;
    
    if (_rtcHost != NULL && [_rtcHost rangeOfString:@"live.rtc.qq.com"].location != NSNotFound) {
        ismyqcloud = false;
    } else if (_rtcHost != NULL && [_rtcHost rangeOfString:@"webrtc.liveplay.myqcloud.com"].location != NSNotFound) {
        ismyqcloud = true;
    }
    
    if (!ismyqcloud) {
           host = @"https://live.rtc.qq.com";
           rtcUrl = [host stringByAppendingString:@":8687/webrtc/v1/pullstream"];
       } else {
           host= @"https://webrtc.liveplay.myqcloud.com";
           rtcUrl = [host stringByAppendingString:@"/webrtc/v1/pullstream"];
       }
    
//        NSString *host= @"https://live.rtc.qq.com";
//        NSString *rtcUrl = [host stringByAppendingString:@":8687/webrtc/v1/stopstream"];
    
    if(_svrsig == nil || _liveBroadcastingStreamUrl == nil) {
        return;
    }
    NSDictionary *liveJson = @{
        @"svrsig" : _svrsig,
        @"streamurl"  : _liveBroadcastingStreamUrl
    };
    
    NSData *requestData = [NSJSONSerialization dataWithJSONObject:liveJson options:0 error:nil];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rtcUrl]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = requestData;
    [request addValue:host forHTTPHeaderField:@"origin"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
//    __weak ARDAppClient *weakSelf = self;
    [ARDAppClient sendAsyncRequest:request
                    completionHandler:^(NSURLResponse *response,
                                        NSData *data,
                                        NSError *error) {
        
//        NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//        NSInteger errcode = [[responseJSON objectForKey:@"errcode"] intValue];
        
    }];
}

- (void)defaultRemoteDescription:(RTCSessionDescription *)localSDP
       liveBroadcastingStreamUrl:(NSString*)liveBroadcastingStreamUrl
               completionHandler:(nullable void (^)(NSError *_Nullable error))completionHandler {
    
    //https://live.rtc.qq.com/webrtc/v1/pullstream
    NSString *host = NULL;
    NSString *rtcUrl = NULL;
    bool ismyqcloud = false;
    
    if (_rtcHost != NULL && [_rtcHost rangeOfString:@"live.rtc.qq.com"].location != NSNotFound) {
        ismyqcloud = false;
    } else if (_rtcHost != NULL && [_rtcHost rangeOfString:@"webrtc.liveplay.myqcloud.com"].location != NSNotFound) {
        ismyqcloud = true;
    }
       
    
//     host= @"https://live.rtc.qq.com";
//     rtcUrl = [host stringByAppendingString:@":8687/webrtc/v1/pullstream"];
     
    if (!ismyqcloud) {
        host = @"https://live.rtc.qq.com";
        rtcUrl = [host stringByAppendingString:@":8687/webrtc/v1/pullstream"];
    } else {
        host= @"https://webrtc.liveplay.myqcloud.com";
        rtcUrl = [host stringByAppendingString:@"/webrtc/v1/pullstream"];
    }
    
//     NSString *url = @"webrtc://6721.liveplay.now.qq.com/live/";
//     url = [url stringByAppendingString:@"6721_c21f14dc5c3ce1b2513f5810f359ea15?txSecret=c96521895c01742114c033f3cb585339&txTime=5DDE5CBC"];
     
     NSDictionary *sdpJson = @{
         @"sdp"  : localSDP.sdp,
         @"type" : @"offer"
     };
     
     if (liveBroadcastingStreamUrl == NULL) {
//         liveBroadcastingStreamUrl = @"webrtc://6721.liveplay.now.qq.com/live/6721_c21f14dc5c3ce1b2513f5810f359ea15?txSecret=c96521895c01742114c033f3cb585339&txTime=5DDE5CBC";
         
         if (!ismyqcloud) {
             liveBroadcastingStreamUrl = @"webrtc://6721.liveplay.now.qq.com/live/6721_c21f14dc5c3ce1b2513f5810f359ea15?txSecret=c96521895c01742114c033f3cb585339&txTime=5DDE5CBC";
         } else{
             liveBroadcastingStreamUrl=@"webrtc://6721.liveplay.myqcloud.com/live/6721_d71956d9cc93e4a467b11e06fdaf039a";
         }
     }
    
    
    

     NSDictionary *liveJson = @{
         @"clientinfo" : _clientInfo != nil ?  _clientInfo : @"clientinfo_test",
       @"localsdp"   : sdpJson,
       @"sessionid"  : _sessionid != nil ? _sessionid : @"IOS_Test",
       @"streamurl"  : liveBroadcastingStreamUrl
     };

    RTCLog(@"sendAsyncRequest requestData=%@", [NSString stringWithFormat:@"liveJson=%@", liveJson]);
    
     NSData *requestData = [NSJSONSerialization dataWithJSONObject:liveJson options:0 error:nil];
     NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:rtcUrl]];
     request.HTTPMethod = @"POST";
     request.HTTPBody = requestData;
     [request addValue:host forHTTPHeaderField:@"origin"];
     [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
     
    __weak ARDAppClient *weakSelf = self;
     [ARDAppClient sendAsyncRequest:request
                     completionHandler:^(NSURLResponse *response,
                                         NSData *data,
                                         NSError *error) {
        if (error) {
            if (completionHandler) {
                completionHandler(error);
            }
         
            return;
        }
         
         NSDictionary *responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
         
//         __weak RTCPeerConnection *weakSelf = self;
         ARDAppClient *strongSelf = weakSelf;
//         NSDictionary *responseJSON = [NSDictionary dictionaryWithJSONData:data];
         
         RTCLog(@"sendAsyncRequest responseJSON=%@", [NSString stringWithFormat:@"responseJSON=%@", responseJSON]);
         
         NSInteger errcode = [[responseJSON objectForKey:@"errcode"] intValue];
         if (errcode != 0) {
             return;
         }
         
         NSDictionary *sdpDict = [responseJSON objectForKey:@"remotesdp"];
         strongSelf->_svrsig = [responseJSON objectForKey:@"svrsig"];
         //NSString *answerType = [sdpDict objectForKey:@"type"];
         //NSString *answerSDP = [sdpDict objectForKey:@"sdp"];
         
         RTCSessionDescription *description = [ARDAppClient descriptionFromJSONDictionary:sdpDict];
         
         [strongSelf.peerConnection setRemoteDescription:description
                             completionHandler:^(NSError *error) {
             
             RTCLog(@"sendAsyncRequest setRemoteDescription=%@", error);
             
             if (completionHandler) {
                 completionHandler(error);
             }
        //           ARDAppClient *strongSelf = weakSelf;
        //           [strongSelf peerConnection:strongSelf.peerConnection
        //               didSetSessionDescriptionWithError:error];
         }];
     }];
}


-(void)connectLiveBroadcast {
    if (_useLiveEventBroadcasting) {
        ARDAppClient *strongSelf = self;
        
        strongSelf.roomId = @"";
        strongSelf.clientId = @"";
        strongSelf.isInitiator = TRUE;
        strongSelf.hasReceivedSdp = YES;
        strongSelf.webSocketURL = nil;
        strongSelf.webSocketRestURL = nil;
        
        // Create peer connection.
        RTCMediaConstraints *constraints = [self defaultPeerConnectionConstraints];
        RTCConfiguration *config = [[RTCConfiguration alloc] init];
        //        RTCCertificate *pcert = [RTCCertificate generateCertificateWithParams:@{
        //          @"expires" : @100000,
        //          @"name" : @"RSASSA-PKCS1-v1_5"
        //        }];
        //        config.iceServers = _iceServers;
        //        config.certificate = pcert;
        config.sdpSemantics = RTCSdpSemanticsUnifiedPlan;


        _peerConnection = [_factory peerConnectionWithConfiguration:config
                                                        constraints:constraints
                                                           delegate:self];
        
        if (_isInitiator) {
          // Send offer.
          __weak ARDAppClient *weakSelf = self;
          [_peerConnection offerForConstraints:[self defaultOfferConstraints]
                             completionHandler:^(RTCSessionDescription *sdp,
                                                 NSError *error) {
            ARDAppClient *strongSelf = weakSelf;
              
              dispatch_async(dispatch_get_main_queue(), ^{
                if (error) {
                  RTCLogError(@"Failed to create session description. Error: %@", error);
                  [self disconnect];
                  NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"Failed to create session description.",
                  };
                  NSError *sdpError =
                      [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                                 code:kARDAppClientErrorCreateSDP
                                             userInfo:userInfo];
                  [weakSelf.delegate appClient:self didError:sdpError];
                  return;
                }

                  
                __weak ARDAppClient *weakSelf = self;
                [weakSelf.peerConnection setLocalDescription:sdp
                               completionHandler:^(NSError *error) {

                if (error) {
                      RTCLogError(@"Failed to set session description. Error: %@", error);
                      [weakSelf disconnect];
                      NSDictionary *userInfo = @{
                        NSLocalizedDescriptionKey: @"Failed to set session description.",
                      };
                      NSError *sdpError =
                          [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                                     code:kARDAppClientErrorSetSDP
                                                 userInfo:userInfo];
                      [weakSelf.delegate appClient:self didError:sdpError];
                      return;
                }
                }];

                if (weakSelf.isInitiator) {
                  [weakSelf  defaultRemoteDescription:sdp
                  liveBroadcastingStreamUrl:strongSelf->_liveBroadcastingStreamUrl
                                                   completionHandler:^(NSError *error) {
                      
                      self.state = kARDAppClientStateConnected;
                      
                  }];
                    
                    [self setMaxBitrateForPeerConnectionVideoSender];
                }
                  
                
              });
          }];
        }
    }
}

- (void)configure {
  _messageQueue = [NSMutableArray array];
  _iceServers = [NSMutableArray array];
  _fileLogger = [[RTCFileLogger alloc] init];
  [_fileLogger start];
}

- (void)dealloc {
  self.shouldGetStats = NO;
  [self disconnect];
}

- (void)setShouldGetStats:(BOOL)shouldGetStats {
  if (_shouldGetStats == shouldGetStats) {
    return;
  }
  if (shouldGetStats) {
    __weak ARDAppClient *weakSelf = self;
    _statsTimer = [[ARDTimerProxy alloc] initWithInterval:1
                                                  repeats:YES
                                             timerHandler:^{
      ARDAppClient *strongSelf = weakSelf;
      [strongSelf.peerConnection statsForTrack:nil
                              statsOutputLevel:RTCStatsOutputLevelDebug
                             completionHandler:^(NSArray *stats) {
        dispatch_async(dispatch_get_main_queue(), ^{
          ARDAppClient *strongSelf = weakSelf;
          [strongSelf.delegate appClient:strongSelf didGetStats:stats];
        });
      }];
    }];
  } else {
    [_statsTimer invalidate];
    _statsTimer = nil;
  }
  _shouldGetStats = shouldGetStats;
}

- (void)setState:(ARDAppClientState)state {
  if (_state == state) {
    return;
  }
  _state = state;
  [_delegate appClient:self didChangeState:_state];
}

- (void)initWithSettings:(ARDSettingsModel *)settings
                 isLoopback:(BOOL)isLoopback {
//  NSParameterAssert(roomId.length);
  NSParameterAssert(_state == kARDAppClientStateDisconnected);
  _settings = settings;
  _isLoopback = isLoopback;
  self.state = kARDAppClientStateConnecting;

  RTCDefaultVideoDecoderFactory *decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
  RTCDefaultVideoEncoderFactory *encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
    
    NSDictionary<NSString *, NSString *> *constrainedHighParams = @{
        @"profile-level-id" : @"42e01f",
        @"level-asymmetry-allowed" : @"1",
        @"packetization-mode" : @"1",
      };
      RTCVideoCodecInfo *constrainedHighInfo =
          [[RTCVideoCodecInfo alloc] initWithName:@"H264"
                                       parameters:constrainedHighParams];
      
    encoderFactory.preferredCodec = constrainedHighInfo;
    
    
//  encoderFactory.preferredCodec = [settings currentVideoCodecSettingFromStore];
  _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory:encoderFactory
                                                       decoderFactory:decoderFactory];

#if defined(WEBRTC_IOS)
  if (kARDAppClientEnableTracing) {
    NSString *filePath = [self documentsFilePathForFileName:@"webrtc-trace.txt"];
    RTCStartInternalCapture(filePath);
  }
#endif

}

- (void)disconnect {
  if (_state == kARDAppClientStateDisconnected) {
    return;
  }

  _clientId = nil;
  _roomId = nil;
  _isInitiator = NO;
  _hasReceivedSdp = NO;
  _messageQueue = [NSMutableArray array];
  _localVideoTrack = nil;
#if defined(WEBRTC_IOS)
  [_factory stopAecDump];
  [_peerConnection stopRtcEventLog];
#endif
  [_peerConnection close];
  _peerConnection = nil;
  self.state = kARDAppClientStateDisconnected;
#if defined(WEBRTC_IOS)
  if (kARDAppClientEnableTracing) {
    RTCStopInternalCapture();
  }
#endif
    
    [self stopStream];
}

#pragma mark - RTCPeerConnectionDelegate
// Callbacks for this delegate occur on non-main thread and need to be
// dispatched back to main queue as needed.

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeSignalingState:(RTCSignalingState)stateChanged {
  RTCLog(@"Signaling state changed: %ld", (long)stateChanged);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
          didAddStream:(RTCMediaStream *)stream {
  RTCLog(@"Stream with %lu video tracks and %lu audio tracks was added.",
         (unsigned long)stream.videoTracks.count,
         (unsigned long)stream.audioTracks.count);
    
    
    [_delegate appClient:self didReceiveRemoteVideoTrack:stream.videoTracks[0]];
    [_delegate appClient:self didReceiveRemoteAudioTrack:stream.audioTracks[0]];
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didStartReceivingOnTransceiver:(RTCRtpTransceiver *)transceiver {
  RTCMediaStreamTrack *track = transceiver.receiver.track;
  RTCLog(@"Now receiving %@ on track %@.", track.kind, track.trackId);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
       didRemoveStream:(RTCMediaStream *)stream {
  RTCLog(@"Stream was removed.");
}

- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection {
  RTCLog(@"WARNING: Renegotiation needed but unimplemented.");
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeIceConnectionState:(RTCIceConnectionState)newState {
  RTCLog(@"ICE state changed: %ld", (long)newState);
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate appClient:self didChangeConnectionState:newState];
  });
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeConnectionState:(RTCPeerConnectionState)newState {
  RTCLog(@"ICE+DTLS state changed: %ld", (long)newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeIceGatheringState:(RTCIceGatheringState)newState {
  RTCLog(@"ICE gathering state changed: %ld", (long)newState);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didGenerateIceCandidate:(RTCIceCandidate *)candidate {

}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates {
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
     didChangeLocalCandidate:(RTCIceCandidate *)local
    didChangeRemoteCandidate:(RTCIceCandidate *)remote
              lastReceivedMs:(int)lastDataReceivedMs
               didHaveReason:(NSString *)reason {
  RTCLog(@"ICE candidate pair changed because: %@", reason);
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel {
}

#pragma mark - Private

#if defined(WEBRTC_IOS)

- (NSString *)documentsFilePathForFileName:(NSString *)fileName {
  NSParameterAssert(fileName.length);
  NSArray *paths = NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirPath = paths.firstObject;
  NSString *filePath =
      [documentsDirPath stringByAppendingPathComponent:fileName];
  return filePath;
}

#endif

- (BOOL)hasJoinedRoomServerRoom {
  return _clientId.length;
}

// Sends a signaling message to the other client. The caller will send messages
// through the room server, whereas the callee will send messages over the
// signaling channel.
- (void)sendSignalingMessage:(ARDSignalingMessage *)message {
  if (_isInitiator) {
    __weak ARDAppClient *weakSelf = self;
    [_roomServerClient sendMessage:message
                         forRoomId:_roomId
                          clientId:_clientId
                 completionHandler:^(ARDMessageResponse *response,
                                     NSError *error) {
      ARDAppClient *strongSelf = weakSelf;
      if (error) {
        [strongSelf.delegate appClient:strongSelf didError:error];
        return;
      }
      NSError *messageError =
          [[strongSelf class] errorForMessageResultType:response.result];
      if (messageError) {
        [strongSelf.delegate appClient:strongSelf didError:messageError];
        return;
      }
    }];
  } else {
    [_channel sendMessage:message];
  }
}

- (void)setMaxBitrateForPeerConnectionVideoSender {
  for (RTCRtpSender *sender in _peerConnection.senders) {
    if (sender.track != nil) {
      if ([sender.track.kind isEqualToString:kARDVideoTrackKind]) {
        [self setMaxBitrate:[_settings currentMaxBitrateSettingFromStore] forVideoSender:sender];
      }
    }
  }
}

- (void)setMaxBitrate:(NSNumber *)maxBitrate forVideoSender:(RTCRtpSender *)sender {
  if (maxBitrate.intValue <= 0) {
    return;
  }

  RTCRtpParameters *parametersToModify = sender.parameters;
  for (RTCRtpEncodingParameters *encoding in parametersToModify.encodings) {
    encoding.maxBitrateBps = @(maxBitrate.intValue * kKbpsMultiplier);
  }
  [sender setParameters:parametersToModify];
}

- (RTCRtpTransceiver *)videoTransceiver {
  for (RTCRtpTransceiver *transceiver in _peerConnection.transceivers) {
    if (transceiver.mediaType == RTCRtpMediaTypeVideo) {
      return transceiver;
    }
  }
  return nil;
}

#pragma mark - Defaults

 - (RTCMediaConstraints *)defaultMediaAudioConstraints {
   NSDictionary *mandatoryConstraints = @{};
   RTCMediaConstraints *constraints =
       [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                             optionalConstraints:nil];
   return constraints;
}

- (RTCMediaConstraints *)defaultAnswerConstraints {
  return [self defaultOfferConstraints];
}

- (RTCMediaConstraints *)defaultOfferConstraints {
  NSDictionary *mandatoryConstraints = @{
    @"OfferToReceiveAudio" : @"true",
    @"OfferToReceiveVideo" : @"true"
  };
  RTCMediaConstraints* constraints =
      [[RTCMediaConstraints alloc]
          initWithMandatoryConstraints:mandatoryConstraints
                   optionalConstraints:nil];
  return constraints;
}

- (RTCMediaConstraints *)defaultPeerConnectionConstraints {
  if (_defaultPeerConnectionConstraints) {
    return _defaultPeerConnectionConstraints;
  }
  NSString *value = @"true";
  NSDictionary *optionalConstraints = @{ @"DtlsSrtpKeyAgreement" : value };
  RTCMediaConstraints* constraints =
      [[RTCMediaConstraints alloc]
          initWithMandatoryConstraints:nil
                   optionalConstraints:optionalConstraints];
  return constraints;
}

#pragma mark - Errors

+ (NSError *)errorForJoinResultType:(ARDJoinResultType)resultType {
  NSError *error = nil;
  switch (resultType) {
    case kARDJoinResultTypeSuccess:
      break;
    case kARDJoinResultTypeUnknown: {
      error = [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                         code:kARDAppClientErrorUnknown
                                     userInfo:@{
        NSLocalizedDescriptionKey: @"Unknown error.",
      }];
      break;
    }
    case kARDJoinResultTypeFull: {
      error = [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                         code:kARDAppClientErrorRoomFull
                                     userInfo:@{
        NSLocalizedDescriptionKey: @"Room is full.",
      }];
      break;
    }
  }
  return error;
}

+ (NSError *)errorForMessageResultType:(ARDMessageResultType)resultType {
  NSError *error = nil;
  switch (resultType) {
    case kARDMessageResultTypeSuccess:
      break;
    case kARDMessageResultTypeUnknown:
      error = [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                         code:kARDAppClientErrorUnknown
                                     userInfo:@{
        NSLocalizedDescriptionKey: @"Unknown error.",
      }];
      break;
    case kARDMessageResultTypeInvalidClient:
      error = [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                         code:kARDAppClientErrorInvalidClient
                                     userInfo:@{
        NSLocalizedDescriptionKey: @"Invalid client.",
      }];
      break;
    case kARDMessageResultTypeInvalidRoom:
      error = [[NSError alloc] initWithDomain:kARDAppClientErrorDomain
                                         code:kARDAppClientErrorInvalidRoom
                                     userInfo:@{
        NSLocalizedDescriptionKey: @"Invalid room.",
      }];
      break;
  }
  return error;
}

@end
