//
//  Mp3Converter.m
//  MP3Lover
//
//  Created by tien dh on 12/30/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mp3Converter.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>

@implementation Mp3Converter

+(void)getAudioFromVideo:(NSString*)videoPath callback:(void (^)(NSString*,bool))result {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *audioPath = [documentsDirectory stringByAppendingPathComponent:@"temp.m4a"];
    
    NSURL *videoURL = [NSURL fileURLWithPath:videoPath];
    AVAsset *myasset = [AVAsset assetWithURL:videoURL];
    
    AVAssetExportSession *exportSession=[AVAssetExportSession exportSessionWithAsset:myasset presetName:AVAssetExportPresetPassthrough];
    
    exportSession.outputURL=[NSURL fileURLWithPath:audioPath];
    exportSession.outputFileType=AVFileTypeAppleM4A;
    
    CMTimeRange exportTimeRange = CMTimeRangeMake(kCMTimeZero, [myasset duration]);
    exportSession.timeRange= exportTimeRange;
    if ([[NSFileManager defaultManager] fileExistsAtPath:audioPath]) {
        [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
    }
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        if (exportSession.status==AVAssetExportSessionStatusFailed) {
            result(nil,NO);
        } else {
            result(audioPath,YES);
        }
    }];
}

@end
