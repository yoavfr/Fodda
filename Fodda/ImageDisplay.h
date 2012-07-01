//
//  ImageDisplay.h
//  Fodda
//
//  Created by Yoav Frandzel on 6/30/12.
//  Copyright (c) 2012 Yoav.Frandzel@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ImageDisplay <NSObject>

@required
-(void) updateWithImage: (NSImage*) image;
-(void) operationDone;

@end

