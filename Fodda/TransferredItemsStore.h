//
//  TransferredItemsStore.h
//  Fodda
//
//  Created by Yoav Frandzel on 7/27/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransferredItemsStore : NSObject
{
    NSMutableOrderedSet* _items;
}

-(id) init;
-(void) load;
-(void) store;
-(void) add:(NSString*)uniqueName;
-(BOOL) exists:(NSString*)uniqueName;


@end
