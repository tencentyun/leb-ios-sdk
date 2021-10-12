//
//  ConvertWAV.h
//  LiveEB_Demo
//
//  Created by ts on 6/4/21.
//  Copyright © 2021 ts. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConvertWAV : NSObject


-(void) convertAudio:(NSURL*)url outputURL:(NSURL*)outputURL;

+(void)testOutputFile;

@end

NS_ASSUME_NONNULL_END
