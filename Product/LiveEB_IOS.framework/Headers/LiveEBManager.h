//
//  LiveEBManager.h
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN




typedef enum {
    LiveEBLogLevelVerbose,
    LiveEBLogLevelDebug,
    LiveEBLogLevelInfo,
    LiveEBLogLevelWarning,
    LiveEBLogLevelError,
    LiveEBLogLevelSystem,
} LiveEBLogLevel;

@protocol LiveEBLogDelegate <NSObject>

@required

/**
 日志打印接口
 
 @param logLevel 日志打印级别
 @param tag 日志tag
 @param file 文件名称
 @param function 函数名称
 @param line 代码行
 @param format format
 @param args args
 */
- (void)logWithLevel:(LiveEBLogLevel)logLevel
                 tag:(NSString *)tag
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line
              format:(NSString *)format
                args:(va_list)args;

/**
 播放器内部没有日志打印模块，为便于问题定位，APP要实现此日志打印接口，方便将播放器内的日志打印到APP的日志中，方便问题定位
 */


@end


@interface LiveEBManager : NSObject


+ (instancetype)sharedManager;

@property (nonatomic, copy) NSString *clientInfo;

-(void)initSDK:(id<LiveEBLogDelegate>) logDelegate;

-(void)finitSDK;



@end

NS_ASSUME_NONNULL_END
