//
//  LEBStatReport.h
//  LiveEB_IOS
//
//  Created by ts on 7/6/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LEBStatReport : NSObject

@property (nonatomic, assign) float fps;
@property (nonatomic, assign) NSUInteger rtt;

@property (nonatomic, assign) uint32_t  audioSampleRate;

@property (nonatomic, assign) NSUInteger audioDelay;
@property (nonatomic, assign) NSUInteger audioLost;
@property (nonatomic, assign) NSUInteger audioJitterBuffer;

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


- (NSString *)description;

@end

NS_ASSUME_NONNULL_END
