//
//  IRGroupConversation.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-27.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRMessage.h"
#import "IRGroup.h"

@interface IRGroupConversation : NSObject
{
    NSInteger timeLeftOnConversation;
}

@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) IRGroup *group;
@property (nonatomic, retain) NSDate *startedAt;

@end
