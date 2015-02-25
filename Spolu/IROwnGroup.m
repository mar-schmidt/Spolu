//
//  IROwnGroup.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-25.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IROwnGroup.h"

@implementation IROwnGroup

+ (id)sharedGroup {
    static IRGroup *sharedIRGroup = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIRGroup = [[self alloc] init];
    });
    
    return sharedIRGroup;
}

@end
