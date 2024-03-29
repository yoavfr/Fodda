//
//  AppDelegate.h
//  Fodda
//
//  Created by Yoav Frandzel on 6/22/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "FileCopyOperation.h"
#import "ImageDisplay.h"
#import "TransferredItemsStore.h"

@interface AppDelegate: NSObject <NSApplicationDelegate, ImageDisplay>
{
    @private
    BOOL _overwrite;
    BOOL _newOnly;
    FileCopyOperation *_fileCopyOperation;
    NSOperationQueue* _operationQueue;
    TransferredItemsStore* _itemStore;
    
}
@property (assign) IBOutlet NSWindow *window;
- (IBAction)findSource:(id)sender;

- (IBAction)findDestination:(id)sender;
- (IBAction)startStop:(id)sender;
@property (assign) IBOutlet NSTextField *sourceBox;
@property (assign) IBOutlet NSTextField *destinationBox;
- (IBAction)overwrite:(id)sender;
@property (assign) IBOutlet NSButton *overwriteCheckBox;
@property (assign) IBOutlet NSImageView *previewImage;
@property (assign) IBOutlet NSButton *findDestinationButton;
@property (assign) IBOutlet NSButton *findSourceButton;
@property (assign) IBOutlet NSButton *startButton;
@property (assign) IBOutlet NSButton *onlyNewCheckBox;
- (IBAction)onlyNew:(id)sender;

- (BOOL) copy:(NSString*) source toDestination: (NSString*) destination;

- (BOOL) saveDefaults:(id)sender;
@property (assign) IBOutlet NSUserDefaultsController *defaultsController;
@end
