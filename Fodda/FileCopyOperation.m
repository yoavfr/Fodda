//
//  FileCopyOperation.m
//  Fodda
//
//  Created by Yoav Frandzel on 6/30/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import "FileCopyOperation.h"

@implementation FileCopyOperation

-(id)initWithSource:(NSString*) source destination: (NSString*) destination overwrite:(BOOL)overwrite newOnly:(BOOL) newOnly display: (id<ImageDisplay>) display itemStore: (TransferredItemsStore*) itmeStore
{
    self = [super init];
    if (self != nil)
    {
        _source = source;
        _destination = destination;
        _overwrite = overwrite;
        _display = display;
        _newOnly = newOnly;
        _itemStore = itmeStore;
    }
    return self;
}

- (void) main
{
        [self doCopyFrom:_source];
        [_display operationDone];
}

- (void) doCopyFrom:(NSString *)source
{
    NSLog(@"doCopy");
    NSString *current;
    NSString *currentFullPath;
    NSError *error;
    NSString *uniqueFileId;
    NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:source];
    // for each entry
    while (current = [enumerator nextObject])
    {
        // lots of expensive allocations in here - deallocate autoreleased objects on each iteration
        @autoreleasepool 
        {
            // check for halt
            if (_halt)
            {
                return;
            }
            
            // full path of entry
            currentFullPath = [source stringByAppendingPathComponent:current];
            
            // check if it is a directory
            BOOL isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath: currentFullPath isDirectory:&isDirectory];
            
            // if a directory - recurse
            if (isDirectory)
            {
                [self doCopyFrom:currentFullPath];
            }
            // otherwise a file
            else
            {
                // extract the file extension
                NSString *extension = [current pathExtension];
                
                NSImage *image;
                // if jpg or img load image
                if ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame || 
                    [extension caseInsensitiveCompare:@"img"] == NSOrderedSame)
                {
                    image = [[[NSImage alloc] initWithContentsOfFile:currentFullPath] autorelease]; 
                }
                // if mov or avi load first frame
                else if ([extension caseInsensitiveCompare:@"mov"] == NSOrderedSame || 
                         [extension caseInsensitiveCompare:@"avi"] == NSOrderedSame)
                {
                    image = [FileCopyOperation thumbnailImageForVideo:[[[NSURL alloc] initFileURLWithPath:currentFullPath] autorelease] atTime:0];
                }
                // for the rest don't do anything
                else
                {
                    continue;
                }
                
                // skip other file extensions
                if (image != nil)
                {
                    [_display updateWithImage: image];
                }
                
                // extract file attributes
                NSLog(@"%@",currentFullPath);
                NSDictionary* fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:currentFullPath error:nil];
                
                // extract file creation date (TODO: use exif data instead)
                NSDate *creationDate = [fileAttributes fileCreationDate];
                NSLog(@"created on: %@", creationDate);
                NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:creationDate];
                
                // format destination folder from date components
                NSString *destinationFolder = [_destination stringByAppendingFormat:@"/%04d/%04d_%02d/%04d_%02d_%02d", [dateComponents year], [dateComponents year], [dateComponents month], [dateComponents year], [dateComponents month], [dateComponents day]];
                // full file name = destination folder/filename
                NSString *destinationFullPath = [destinationFolder stringByAppendingFormat:@"/%@", current];
                
                uniqueFileId = [NSString stringWithFormat:@"%.0f/%@",[creationDate timeIntervalSince1970] ,current];
                
                // check if we have downloaded this image already, skip if we want to download only new files
                if (_newOnly && [_itemStore exists:uniqueFileId])
                {
                    NSLog(@"Seen %@, Skipping",destinationFullPath);
                    continue;
                }
                
                // create the destination folder if necessary            
                if (![[NSFileManager defaultManager] fileExistsAtPath:destinationFolder])
                {
                    if (![[NSFileManager defaultManager] createDirectoryAtPath:destinationFolder withIntermediateDirectories:YES attributes:nil error:&error])
                    {
                        NSLog(@"%@",[error localizedDescription]);
                    }
                }
                
                // check if overwrite
                if ([[NSFileManager defaultManager] fileExistsAtPath:destinationFullPath])
                {
                    if (!_overwrite)
                    {
                        NSLog(@"Exists, skipping");
                        continue;
                    }
                    else
                    {
                        // delete if already exists and need to overwrite
                        if (![[NSFileManager defaultManager] removeItemAtPath:destinationFullPath error:&error])
                        {
                            NSLog(@"%@",[error localizedDescription]); 
                        }
                    }
                }
                
                // copy
                NSLog(@"Copying %@ -> %@",currentFullPath, destinationFullPath);
                if (![[NSFileManager defaultManager] copyItemAtPath:currentFullPath toPath:destinationFullPath error:&error])
                {
                    NSLog(@"Failed. %@", [error localizedDescription]);
                }
                else
                {
                    [_itemStore add:uniqueFileId];
                }
            }
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
