//
//  IRMatchedGroups.m
//  
//
//  Created by Marcus Ronélius on 2015-02-24.
//
//

#import "IRMatchedGroups.h"

@implementation IRMatchedGroups

- (id)init
{
    self = [super init];
    if (self) {
        //NSArray *randomGroups = @[[self randomGroupWithId:1], [self randomGroupWithId:2], [self randomGroupWithId:3], [self randomGroupWithId:4], [self randomGroupWithId:5], [self randomGroupWithId:6], [self randomGroupWithId:7]];
        _groups = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)sharedMatchedGroups {
    static IRMatchedGroups *sharedIRMatchedGroups = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIRMatchedGroups = [[self alloc] init];
    });
    
    return sharedIRMatchedGroups;
}

@end
