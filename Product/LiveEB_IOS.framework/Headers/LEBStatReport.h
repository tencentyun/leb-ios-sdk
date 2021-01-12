//
//  LEBStatReport.h
//  LiveEB_IOS
//
//  Created by ts on 7/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//video
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

@interface LEBStatReport : NSObject

@property (nonatomic, assign) float fps;
@property (nonatomic, assign) NSUInteger rtt;

//audio
@property (nonatomic, assign) uint32_t  audioSampleRate;

@property (nonatomic, assign) NSUInteger audioDelay;
@property (nonatomic, assign) NSUInteger audioLost;
@property (nonatomic, assign) NSUInteger audioJitterBuffer;

//viedo
@property (nonatomic, assign) NSUInteger videoDelay;
@property (nonatomic, assign) NSUInteger videoLost;
@property (nonatomic, assign) NSUInteger videoJitterBuffer;

@property (nonatomic, assign) NSUInteger videoNack;
@property (nonatomic, assign) NSUInteger delay;
@property (nonatomic, assign) NSUInteger packetsLost;
@property (nonatomic, assign) NSUInteger packetsReceived;

@property (nonatomic, assign) int64_t bytesReceived;
@property (nonatomic, assign) int64_t lastbytesReceived;
@property (nonatomic, assign) int64_t nackCount;


@property (nonatomic, assign) int64_t lastRecevieTime;
@property (nonatomic, assign) int64_t lastRecevieTimeStamp;
@property (nonatomic, assign) int64_t lastRecevieFrame;

- (NSString *)description;
@end



NS_ASSUME_NONNULL_END
