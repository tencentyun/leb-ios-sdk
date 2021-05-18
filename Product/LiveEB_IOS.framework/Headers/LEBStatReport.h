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

@property (nonatomic, assign) uint32_t  audioSampleRate;

@property (nonatomic, assign) NSUInteger audioNack;
@property (nonatomic, assign) NSUInteger audioDelayMs;
@property (nonatomic, assign) NSUInteger audioPacketsLost;
@property (nonatomic, assign) NSUInteger audioPacketsReceived;
@property (nonatomic, assign) NSUInteger audioJitterBuffer;
@property (nonatomic, assign) int64_t    audioBytesReceived;
@property (nonatomic, assign) NSUInteger rtt;

@end


/*
 * recevier video track统计相关
 */
@interface LEBVideoTrackReceiverStatReport : NSObject

@property (nonatomic, assign) NSUInteger videoDelayMs;
@property (nonatomic, assign) NSUInteger videoPacketsLost;
@property (nonatomic, assign) NSUInteger videoJitterBuffer;

@property (nonatomic, assign) NSUInteger videoNack;
@property (nonatomic, assign) NSUInteger videoPacketsReceived;

@property (nonatomic, assign) int64_t videoBytesReceived;

@property (nonatomic, assign) float fps;

//VideoQualityObserver
/*卡顿统计标准：max(150ms+平均渲染延迟, 3*平均渲染延迟)*/
/*卡顿总时长 s*/
@property (nonatomic, assign) double videoTotalFreezesDuration;
/*卡顿次数*/
@property (nonatomic, assign) int videoFreezeCount;

/*上一个接收包超过5s 为paused s*/
@property (nonatomic, assign) double videoTotalPausesDuration;
@property (nonatomic, assign) int videoPauseCount;

/*流是否paused*/
@property (nonatomic, assign) BOOL videoIsPaused;

/*距离上一次渲染帧的时长 ms*/
@property (nonatomic, assign) uint32_t videoFromLastFrameRenderedDuraMS;

/*总渲染时长 s*/
@property (nonatomic, assign) double videoTotalFramesDuration;

/*inter frame delay squared s*/
@property (nonatomic, assign) double videoSumSquaredFrameDurationsSec;

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
