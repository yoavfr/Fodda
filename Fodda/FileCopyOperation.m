//
//  FileCopyOperation.m
//  Fodda
//
//  Created by Yoav Frandzel on 6/30/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import "FileCopyOperation.h"

@implementation FileCopyOperation

-(id)initWithSource:(NSString*) source destination: (NSString*) destination overwrite:(BOOL)overwrite display: (id<ImageDisplay>) display
{
    self = [super init];
    if (self != nil)
    {
        _source = source;
        _destination = destination;
        _overwrite = overwrite;
        _display = display;
    }
    return self;
}

- (void) main
{
    @autoreleasepool 
    {
        [self doCopyFrom:_source];
        [_display operationDone];
    }
    
}

- (void) doCopyFrom:(NSString *)source
{
    NSLog(@"doCopy");
    NSString *current;
    NSString *currentFullPath;
    NSError *error;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:source];
    while (current = [enumerator nextObject])
    {
        if (_halt)
        {
            return;
        }
        currentFullPath = [source stringByAppendingPathComponent:current];
        BOOL isDirectory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath: currentFullPath isDirectory:&isDirectory];
        if (!isDirectory)
        {
            NSString *extension = [current pathExtension];
            
            NSImage *image;
            if ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame || 
                [extension caseInsensitiveCompare:@"img"] == NSOrderedSame)
            {
                image = [[NSImage alloc] initWithContentsOfFile:currentFullPath]; 
            }
            else if ([extension caseInsensitiveCompare:@"mov"] == NSOrderedSame || 
                     [extension caseInsensitiveCompare:@"avi"] == NSOrderedSame)
            {
                //AVAssetImageGenerator
                image = [FileCopyOperation thumbnailImageForVideo:[[NSURL alloc] initFileURLWithPath:currentFullPath] atTime:0];
            }
            else
            {
                continue;
            }
            
            if (image != nil)
            {
                [_display updateWithImage:image];
            }
            
            NSLog(@"Copying %@",currentFullPath);
            NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:currentFullPath error:nil];
            NSDate *creationDate = [fileAttributes fileCreationDate];
            NSLog(@"created on: %@", creationDate);
            NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:creationDate];
            
            NSString *destinationFolder = [_destination stringByAppendingFormat:@"/%04d/%04d_%02d/%04d_%02d_%02d", [dateComponents year], [dateComponents year], [dateComponents month], [dateComponents year], [dateComponents month], [dateComponents day]];
            NSString *destinationFullPath = [destinationFolder stringByAppendingFormat:@"/%@", current];
            
            NSLog(@"%@ -> %@",currentFullPath, destinationFullPath);
            
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFolder])
            {
                if (![[NSFileManager defaultManager] createDirectoryAtPath:destinationFolder withIntermediateDirectories:YES attributes:nil error:&error])
                {
                    NSLog(@"%@",[error localizedDescription]);
                }
            }
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:destinationFullPath])
            {
                if (!_overwrite)
                {
                    NSLog(@"Exists, skipping");
                    continue;
                }
                else
                {
                    if (![[NSFileManager defaultManager] removeItemAtPath:destinationFullPath error:&error])
                    {
                        NSLog(@"%@",[error localizedDescription]); 
                    }
                }
            }
            
            
            if (![[NSFileManager defaultManager] copyItemAtPath:currentFullPath toPath:destinationFullPath error:&error])
            {
                NSLog(@"Failed. %@", [error localizedDescription]);
            }
        }
        else
        {
            [self doCopyFrom:currentFullPath];
        }
    }
   
}

+ (NSImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time 
{
    AVURLAsset *asset = [[[AVURLAsset alloc] initWithURL:videoURL options:nil] autorelease];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[[AVAssetImageGenerator alloc] initWithAsset:asset] autorelease];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        NSLog(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    
    NSImage *thumbnailImage = thumbnailImageRef ? [[[NSImage alloc] initWithCGImage:thumbnailImageRef size:NSZeroSize] autorelease] : nil;
    
    return thumbnailImage;
}

- (void) halt
{
    NSLog(@"halting");
    _halt = YES;
}

@end
