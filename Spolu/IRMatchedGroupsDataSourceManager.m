//
//  IRMatchedGroupsDataSourceManager.m
//  
//
//  Created by Marcus Ronélius on 2015-02-24.
//
//

#import "IRMatchedGroupsDataSourceManager.h"

@implementation IRMatchedGroupsDataSourceManager

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
    static IRMatchedGroupsDataSourceManager *_sharedIRMatchedGroupsDataSourceManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedIRMatchedGroupsDataSourceManager = [[self alloc] init];
    });
    
    return _sharedIRMatchedGroupsDataSourceManager;
}

@end
