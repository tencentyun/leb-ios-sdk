//
//  LiveEBFileVideoCapturer.h
//  LiveEB_Demo
//
//  Created by ts on 4/7/21.
//  Copyright © 2021 ts. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <LiveEB_IOS/LiveEB_IOS.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * Error passing block.
 */
typedef void (^RTCFileVideoCapturerErrorBlock)(NSError *error);

@interface LiveEBFileVideoCapturer : NSObject

- (void)startCapturingFromFileNamed:(NSString *)nameOfFile
                            onError:(__nullable RTCFileVideoCapturerErrorBlock)errorBlock;

- (void)stopCapture;

@end

NS_ASSUME_NONNULL_END
