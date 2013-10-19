//
//  AppDelegate.m
//  Fodda
//
//  Created by Yoav Frandzel on 6/22/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate
@synthesize defaultsController = _defaultsController;
@synthesize overwriteCheckBox = _overwriteCheckBox;
@synthesize previewImage = _previewImage;
@synthesize findDestinationButton = _findDestinationButton;
@synthesize findSourceButton = _findSourceButton;
@synthesize startButton = _startButton;
@synthesize onlyNewCheckBox = _onlyNewCheckBox;
@synthesize sourceBox = _sourceBox;
@synthesize destinationBox = _destinationBox;

@synthesize window = _window;


- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _overwrite = [_overwriteCheckBox state];
    _newOnly = [_onlyNewCheckBox state];
    _operationQueue = [[NSOperationQueue alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveDefaults:) name:NSWindowWillCloseNotification object:_window];
    _itemStore = [[TransferredItemsStore alloc] init];
    [_itemStore load];
}

- (BOOL) saveDefaults:(id)sender
{
    NSLog(@"saveDefaults");
    [[NSUserDefaults standardUserDefaults] setValue:[_sourceBox stringValue] forKey:@"sourceFolder"];
    [[NSUserDefaults standardUserDefaults] setValue:[_destinationBox stringValue] forKey:@"destinationFolder"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_overwriteCheckBox state] forKey:@"overwrite"];
    [[NSUserDefaults standardUserDefaults] setInteger:[_onlyNewCheckBox state] forKey:@"onlyNew"];
    [_itemStore store];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSUserDefaults standardUserDefaults] autorelease];
    return YES;
}


- (IBAction)findSource:(id)sender 
{
    void (^handler)(NSInteger);
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:false];
    [panel setCanCreateDirectories:true];
    [panel setCanChooseDirectories:true];
    
    handler = ^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *filePath = [[[panel URLs] objectAtIndex:0] path];
            [_sourceBox setStringValue:filePath];
        }
    };
    
    [panel beginSheetModalForWindow:_window completionHandler: handler];
}

- (IBAction)findDestination:(id)sender 
{
    void (^handler)(NSInteger);
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:false];
    [panel setCanCreateDirectories:true];
    [panel setCanChooseDirectories:true];
    
    handler = ^(NSInteger result)
    {
        if (result == NSFileHandlingPanelOKButton)
        {
            NSString *filePath = [[[panel URLs] objectAtIndex:0] path];
            [_destinationBox setStringValue:filePath];
        }
    };
    
    [panel beginSheetModalForWindow:_window completionHandler: handler];
}



- (IBAction)startStop:(id)sender 
{
    if (_fileCopyOperation != nil)
    {
        [_fileCopyOperation halt];
        return;
    }
    
    [_sourceBox setEnabled:NO];
    [_destinationBox setEnabled:NO];
    [_overwriteCheckBox setEnabled:NO];
    [_onlyNewCheckBox setEnabled:NO];
    [_findSourceButton setEnabled:NO];
    [_findDestinationButton setEnabled:NO];
    [_startButton setTitle:@"Stop"];
    
    
    NSString* source = [_sourceBox stringValue];
    NSString* destination = [_destinationBox stringValue];

    if (![self copy:source toDestination:destination])
    {
        NSLog(@"Failed to copy");
    }

    
}
- (IBAction)overwrite:(id)sender 
{
    _overwrite = [_overwriteCheckBox state];
    NSLog(@"%d",_overwrite);
}

- (IBAction)onlyNew:(id)sender 
{
    _newOnly = [_onlyNewCheckBox state];
    NSLog(@"%d",_newOnly);
}

- (BOOL) copy:(NSString*) source toDestination:(NSString*) destination
{
    _fileCopyOperation = [[[FileCopyOperation alloc] initWithSource:source destination:destination overwrite:_overwrite newOnly: _newOnly display: self itemStore: _itemStore] autorelease];
    [_operationQueue addOperation: _fileCopyOperation];
    
    return true;
}

- (void) updateWithImage: (NSImage*) image
{
    [_previewImage performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
}

- (void) operationDone
{
    NSLog(@"copy done");
    _fileCopyOperation = nil;
    [_sourceBox setEnabled:YES];
    [_destinationBox setEnabled:YES];
    [_overwriteCheckBox setEnabled:YES];
    [_onlyNewCheckBox setEnabled:YES];
    [_findSourceButton setEnabled:YES];
    [_findDestinationButton setEnabled:YES];
    [_startButton setTitle:@"Start"];
}


@end
