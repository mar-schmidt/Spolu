//
//  IRJsonToGroupParser.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRJsonToGroupParser.h"
#import "IRMatchServiceDataSource.h"

@implementation IRJsonToGroupParser

+ (IRJsonToGroupParser *)sharedIRJsonToGroupParser
{
    static IRJsonToGroupParser *_sharedIRJsonToGroupParser = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedIRJsonToGroupParser = [[self alloc] init];
    });
    
    return _sharedIRJsonToGroupParser;
}

- (id)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (NSMutableArray *)parseGroupsFromResponseObject:(id)responseObject
{
    // Create an array with received groups
    NSArray *receivedGroups = responseObject;
    
    // Create an array and populate and IRGroup instance for every group in receivedGroups
    NSMutableArray *groups = [[NSMutableArray alloc] init];
    
    // Loop through the array and create an instance of IRGroup for each received group
    for (NSDictionary *diction in receivedGroups) {
        
        IRGroup *group = [[IRGroup alloc] initWithGroupId:[[diction objectForKey:@"_id"] integerValue]
                                                 imageUrl:[diction objectForKey:@"image"]
                                                   gender:[[diction objectForKey:@"gender"] integerValue]
                                                      age:[[diction objectForKey:@"age"] integerValue]
                                                 distance:[[diction objectForKey:@"distance_km"] integerValue]];
        // Add the recipe to users recipe array
        [groups addObject:group];
    }
    return groups;
}



@end
