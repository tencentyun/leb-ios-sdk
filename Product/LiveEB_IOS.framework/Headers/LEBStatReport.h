//
//  LEBStatReport.h
//  LiveEB_IOS
//
//  Created by ts on 7/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

__attribute__((deprecated("interface LEBRTCStatReport is deprecated, use interface LEBStatReport instead")))
@interface LEBRTCStatReport : NSObject
//VideoQualityObserver
/*卡顿统计标准：max(150ms+平均渲染延迟, 3*平均渲染延迟)*/
/*卡顿总时长 s*/
@property (nonatomic, assign) double totalFreezesDuration;
/*卡顿次数*/
@property (nonatomic, assign) int freezeCount;

/*上一个接收包超过5s 为paused s*/
@property (nonatomic, assign) double totalPausesDuration;
@property (nonatomic, assign) int pauseCount;

/*流是否paused*/
@property (nonatomic, assign) BOOL isPaused;

/*距离上一次渲染帧的时长 ms*/
@property (nonatomic, assign) uint32_t fromLastFrameRenderedDuraMS;

/*总渲染时长 s*/
@property (nonatomic, assign) double totalFramesDuration;

/*inter frame delay squared s*/
@property (nonatomic, assign) double sumSquaredFrameDurationsSec;

@end

/*
 * recevier audio track统计相关
 */
@interface LEBAudioTrackReceiverStatReport : NSObject

@property (nonatomic, assign) uint32_t  sampleRate;

@property (nonatomic, assign) NSUInteger nackCount;
@property (nonatomic, assign) NSUInteger delayMs;
@property (nonatomic, assign) NSUInteger packetsLost;
@property (nonatomic, assign) NSUInteger packetsReceived;
@property (nonatomic, assign) NSUInteger jitterBuffer;
@property (nonatomic, assign) int64_t    bytesReceived;
@property (nonatomic, assign) NSUInteger rtt;
@end


/*
 * recevier video track统计相关
 */
@interface LEBVideoTrackReceiverStatReport : NSObject

@property (nonatomic, assign) NSUInteger delayMs;
@property (nonatomic, assign) NSUInteger packetsLost;
@property (nonatomic, assign) NSUInteger jitterBuffer;

@property (nonatomic, assign) NSUInteger nackCount;
@property (nonatomic, assign) NSUInteger packetsReceived;

@property (nonatomic, assign) int64_t bytesReceived;

@property (nonatomic, assign) NSUInteger googFrameRateReceived;
@property (nonatomic, assign) NSUInteger googFrameRateDecoded;
@property (nonatomic, assign) NSUInteger googFrameRateOutput;
@property (nonatomic, assign) NSUInteger googFrameRendered;


//video BWE
@property (nonatomic, assign) NSUInteger googAvailableReceiveBandwidth;

@property (nonatomic, assign) NSUInteger framesReceived;
@property (nonatomic, assign) NSUInteger framesDecoded;
@property (nonatomic, assign) NSUInteger framesDropped;
//VideoQualityObserver
/*卡顿统计标准：max(150ms+平均渲染延迟, 3*平均渲染延迟)*/
/*卡顿总时长 s*/
@property (nonatomic, assign) double totalFreezesDuration;
/*卡顿次数*/
@property (nonatomic, assign) int freezeCount;

/*上一个接收包超过5s 为paused s*/
@property (nonatomic, assign) double totalPausesDuration;
@property (nonatomic, assign) int pauseCount;

/*流是否paused*/
@property (nonatomic, assign) BOOL isPaused;

/*距离上一次渲染帧的时长 ms*/
@property (nonatomic, assign) uint32_t fromLastFrameRenderedDuraMS;

/*总渲染时长 s*/
@property (nonatomic, assign) double totalFramesDuration;

/*inter frame delay squared s*/
@property (nonatomic, assign) double sumSquaredFrameDurationsSec;

@property (nonatomic, assign) NSUInteger rtt;
@end


@interface LEBStatReport : NSObject

- (instancetype)initWithTrackCount:(int)count;

@property (nonatomic, readonly) NSUInteger trackCount;
@property (nonatomic) NSArray<LEBAudioTrackReceiverStatReport *> *audioTracks;
@property (nonatomic) NSArray<LEBVideoTrackReceiverStatReport *> *videoTracks;

- (NSString *)description;
@end



NS_ASSUME_NONNULL_END
