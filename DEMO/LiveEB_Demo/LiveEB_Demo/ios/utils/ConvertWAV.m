//
//  ConvertWAV.m
//  LiveEB_Demo
//
//  Created by ts on 6/4/21.
//  Copyright © 2021 ts. All rights reserved.
//

#import "ConvertWAV.h"

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>

@implementation ConvertWAV



-(NSString*)getSavePath {
  NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentPath = [path firstObject];
  NSString *defaultPath = [documentPath stringByAppendingPathComponent:@"IMG"];
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  [fileManager createDirectoryAtPath:defaultPath withIntermediateDirectories:NO attributes:nil error:nil];
  
  return defaultPath;
}

-(void) convertAudio:(NSURL*)url outputURL:(NSURL*)outputURL
{
    OSStatus error = noErr;
    ExtAudioFileRef destinationFile = nil;
    ExtAudioFileRef sourceFile = nil;

    AudioStreamBasicDescription srcFormat;
    AudioStreamBasicDescription dstFormat;

    ExtAudioFileOpenURL((__bridge CFURLRef)url, &sourceFile);


    UInt32 thePropertySize = sizeof(srcFormat); //UInt32(MemoryLayout.stride(ofValue: srcFormat));;
    ExtAudioFileGetProperty(sourceFile, kExtAudioFileProperty_FileDataFormat, &thePropertySize, &srcFormat);

    dstFormat.mSampleRate = 44100;  //Set sample rate
    dstFormat.mFormatID = kAudioFormatLinearPCM;
    dstFormat.mChannelsPerFrame = 1;
    dstFormat.mBitsPerChannel = 16;
    dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame;
    dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame;
    dstFormat.mFramesPerPacket = 1;
    dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked | kAudioFormatFlagIsSignedInteger;

    // Create destination file
    error = ExtAudioFileCreateWithURL(
                                      (__bridge CFURLRef)outputURL,
                                      kAudioFileWAVEType,
                                      &dstFormat,
                                      nil,
                                      kAudioFileFlags_EraseFile,
                                      &destinationFile);
    NSLog(@"Error 1 in convertAudio: %d - %@", error, [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil].description);

    error = ExtAudioFileSetProperty(sourceFile,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat);
    NSLog(@"Error 2 in convertAudio: %d - %@", error, [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil].description);

    error = ExtAudioFileSetProperty(destinationFile,
                                    kExtAudioFileProperty_ClientDataFormat,
                                    thePropertySize,
                                    &dstFormat);
    NSLog(@"Error 3 in convertAudio: %d - %@", error, [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil].description);

    const UInt32 bufferByteSize = 32768;
    UInt8 srcBuffer[bufferByteSize];// = [UInt8](repeating: 0, count: 32768)
    memset(srcBuffer, 0, bufferByteSize);
    unsigned long sourceFrameOffset = 0;

    while(true)
    {
        AudioBufferList fillBufList;
        fillBufList.mNumberBuffers = 1;
        fillBufList.mBuffers[0].mNumberChannels = 2;
        fillBufList.mBuffers[0].mDataByteSize = bufferByteSize;
        fillBufList.mBuffers[0].mData = &srcBuffer;

        UInt32 numFrames = 0;

        if(dstFormat.mBytesPerFrame > 0){
            numFrames = bufferByteSize / dstFormat.mBytesPerFrame;
        }

        error = ExtAudioFileRead(sourceFile, &numFrames, &fillBufList);
        NSLog(@"Error 4 in convertAudio: %d - %@", error, [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil].description);

        if(numFrames == 0)
        {
            error = noErr;
            break;
        }

        sourceFrameOffset += numFrames;
        error = ExtAudioFileWrite(destinationFile, numFrames, &fillBufList);
        NSLog(@"Error 5 in convertAudio: %d - %@", error, [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil].description);
    }

    error = ExtAudioFileDispose(destinationFile);
    NSLog(@"Error 6 in convertAudio: %d - %@", error, [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil].description);
    error = ExtAudioFileDispose(sourceFile);
    NSLog(@"Error 7 in convertAudio: %d - %@", error, [NSError errorWithDomain:NSOSStatusErrorDomain code:error userInfo:nil].description);
}


+ (void) testOutputFile {
  ConvertWAV* convert = [[ConvertWAV alloc] init];
  NSString *outfilepath = [convert getSavePath];
  outfilepath = [outfilepath stringByAppendingString:@"/out.wav"];
  NSString *m4apath = [[NSBundle mainBundle] pathForResource: @"out.mp4" ofType:nil];
  [convert convertAudio:m4apath outputURL:outfilepath];
  
  
}

@end
