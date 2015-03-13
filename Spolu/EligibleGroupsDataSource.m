//
//  EligibleGroupsDataSource.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-10.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "EligibleGroupsDataSource.h"

@implementation EligibleGroupsDataSource

+ (EligibleGroupsDataSource *)sharedEligibleGroupsDataSource
{
    static EligibleGroupsDataSource *_sharedEligibleGroupsDataSource = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedEligibleGroupsDataSource = [[self alloc] init];
    });
    
    return _sharedEligibleGroupsDataSource;
}

- (id)init
{
    self = [super init];
    if (self) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)matchServiceHandler:(IRMatchServiceHandler *)service didReceiveEligibleGroups:(NSMutableArray *)groups
{
    _dataSource = groups;
}

- (void)matchServiceHandler:(IRMatchServiceHandler *)service didReceiveMatchWithGroup:(IRGroup *)group
{
    
}

@end