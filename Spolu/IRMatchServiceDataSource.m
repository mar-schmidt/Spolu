//
//  IRMatchServiceDataSource.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-10.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRMatchServiceDataSource.h"

@implementation IRMatchServiceDataSource

+ (IRMatchServiceDataSource *)sharedMatchServiceDataSource
{
    static IRMatchServiceDataSource *_sharedMatchServiceDataSource = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMatchServiceDataSource = [[self alloc] init];
    });
    
    return _sharedMatchServiceDataSource;
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