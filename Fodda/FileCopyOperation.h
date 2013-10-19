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
#import "TransferredItemsStore.h"

@interface FileCopyOperation : NSOperation
{
    NSString *_source;
    NSString *_destination;
    BOOL _overwrite;
    BOOL _newOnly;
    id<ImageDisplay> _display;
    TransferredItemsStore* _itemStore;
    BOOL _halt;
    
}

-(id)initWithSource:(NSString*) source destination: (NSString*) destination overwrite: (BOOL) overwrite newOnly:(BOOL) newOnly display: (id<ImageDisplay>) display itemStore: (TransferredItemsStore*) itmeStore;
- (void) doCopyFrom: (NSString*) source;
- (void) halt;
+ (NSImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time;

@end
