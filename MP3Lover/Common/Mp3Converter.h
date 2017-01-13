//
//  Mp3Converter.h
//  MP3Lover
//
//  Created by tien dh on 12/30/16.
//  Copyright © 2016 tien dh. All rights reserved.
//

#ifndef Mp3Converter_h
#define Mp3Converter_h


@interface Mp3Converter : NSObject
+(void)getAudioFromVideo:(NSString*)videoPath callback:(void (^)(NSString*,bool))result;
@end

#endif /* Mp3Converter_h */
