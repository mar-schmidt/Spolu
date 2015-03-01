//
//  IRGroupConversation.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-27.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRGroupConversation.h"

@implementation IRGroupConversation

- (id)init
{
    self = [super self];
    if (self) {
        _messages = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
