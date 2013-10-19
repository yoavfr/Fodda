//
//  TransferredItemsStore.m
//  Fodda
//
//  Created by Yoav Frandzel on 7/27/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import "TransferredItemsStore.h"

@implementation TransferredItemsStore
static int MAX_ITEMS = 2000;
static NSString* DEFAULTS_ID = @"transferredItems";

-(id)init
{
    self = [super init];
    if (self != nil)
    {
        _items = [[NSMutableOrderedSet alloc] init];
    }
    return self;
}

-(void) load
{
    NSString* str = [[NSUserDefaults standardUserDefaults] valueForKey:DEFAULTS_ID];
    NSArray* lines = [str componentsSeparatedByString:@"\n"];
    NSEnumerator* enumerator = [lines objectEnumerator];
    NSString* current;
    while (current = [enumerator nextObject])
    {
        [_items addObject:current];
    }
    NSLog(@"contents: %@",str);
    
}

-(void) store
{
    NSMutableString* str = [[NSMutableString alloc] init];
    int numItems = (int)[_items count];
    int startIndex = MAX(numItems-MAX_ITEMS,0);
    NSLog(@"items to store %d",numItems);
    for (unsigned long i=startIndex; i<numItems; i++)
    {
        [str appendString:[_items objectAtIndex:i]];
        [str appendString:@"\n"];
    }
    NSLog(@"storing %@",str);
    [[NSUserDefaults standardUserDefaults] setValue:str forKey:DEFAULTS_ID];
}
-(void) add:(NSString*)uniqueName
{
    NSLog(@"Adding %@",uniqueName);
    [_items addObject:uniqueName];
}
-(BOOL) exists:(NSString*)uniqueName
{
    return [_items containsObject:uniqueName];
}
@end
