//
//  LiveEBManager.h
//  LiveEB_IOS
//
//  Created by ts on 4/10/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN




typedef enum {
    LiveEBLogLevelDebug,
    LiveEBLogLevelInfo,
    LiveEBLogLevelWarning,
    LiveEBLogLevelError,
    LiveEBLogLevelNone,
} LiveEBLogLevel;

#define LiveEBLogString(format, ...)                                              \
  [NSString stringWithFormat:@"(%@:%d %s): " format, LiveEBLogFileName(__FILE__), \
                             __LINE__, __FUNCTION__, ##__VA_ARGS__]

#define LiveEBLogFormat(severity, format, ...)                     \
  do {                                                          \
    NSString* log_string = LiveEBLogString(format, ##__VA_ARGS__); \
    LiveEBLogEx(severity, log_string);                             \
  } while (false)

#define LiveEBLogDebug(format, ...) \
  LiveEBLogFormat(LiveEBLogLevelDebug, format, ##__VA_ARGS__)

#define LiveEBLogInfo(format, ...) \
  RTCLogFormat(LiveEBLogLevelInfo, format, ##__VA_ARGS__)

#define LiveEBLogWarning(format, ...) \
  RTCLogFormat(LiveEBLogLevelWarning, format, ##__VA_ARGS__)

#define LiveEBLogError(format, ...) \
  LiveEBLogFormat(LiveEBLogLevelError, format, ##__VA_ARGS__)

#define LiveEBLog(format, ...) LiveEBLogInfo(format, ##__VA_ARGS__)


@protocol LiveEBLogDelegate <NSObject>

@required

/**
 日志打印接口
 
 @param logLevel 日志打印级别
 @param log log
 */
- (void)logWithLevel:(LiveEBLogLevel)logLevel log:(NSString *)log;


@end


static const int64_t  kDefaultMaxFileSize = 10 * 1024 * 1024; // 10MB.

@interface LiveEBManager : NSObject

///【字段含义】播放器遭遇网络连接断开时 SDK 默认重试的次数，取值范围1 - 10，默认值：3。
@property(nonatomic, assign) int connectRetryCount;

///【字段含义】网络重连的时间间隔，单位秒，取值范围3 - 30，默认值：1。
@property(nonatomic, assign) int connectRetryInterval;

///audio jitter buffer max size. default 20
@property(nonatomic, assign) int audioJitterBufferMaxPackets;

///audio acceerate default true
@property(nonatomic, assign) BOOL audioJitterBufferFastAccelerate;


+ (instancetype)sharedManager;

@property (nonatomic, copy) NSString *clientInfo;

/**
 * dirPath  日志保存目录
 * maxFileSize  最大日志文件
 * minDebugLogLevel  日志等级
 */
-(void)initSDK:(NSString*)dirPath maxFileSize:(uint32_t)maxFileSize minDebugLogLevel:(LiveEBLogLevel)minDebugLogLevel;

-(void)initSDK:(NSString*)dirPath maxFileSize:(uint32_t)maxFileSize minDebugLogLevel:(LiveEBLogLevel)minDebugLogLevel
   fieldTrials:( NSDictionary<NSString *, NSString *> * __nullable)fieldTrials ;
/***
 *  logDelegate 日志回调
 */
-(void)initSDK:(id<LiveEBLogDelegate>) logDelegate minDebugLogLevel:(LiveEBLogLevel)minDebugLogLevel;

-(void)initSDK:(id<LiveEBLogDelegate>) logDelegate minDebugLogLevel:(LiveEBLogLevel)minDebugLogLevel
      fieldTrials:(NSDictionary<NSString *, NSString *> * __nullable)fieldTrials;

-(void)finitSDK;



@end

NS_ASSUME_NONNULL_END
