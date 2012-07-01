//
//  FileCopyOperation.h
//  Fodda
//
//  Created by Yoav Frandzel on 6/30/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "ImageDisplay.h"

@interface FileCopyOperation : NSOperation
{
    NSString *_source;
    NSString *_destination;
    BOOL _overwrite;
    id<ImageDisplay> _display;
    BOOL _halt;
    
}

-(id)initWithSource:(NSString*) source destination: (NSString*) destination overwrite: (BOOL) overwrite display: (id<ImageDisplay>) display;
- (void) doCopyFrom: (NSString*) source;
- (void) halt;
+ (NSImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end
