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
        NSArray *randomGroups = @[[self randomGroup], [self randomGroup], [self randomGroup]];
        _groups = [[NSMutableArray alloc] initWithArray:randomGroups];
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
