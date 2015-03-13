//
//  IRJsonToGroupParser.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRJsonToGroupParser.h"

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
    
    // Loop through the array and create an instance of IRGroup for each received group. But first, check if there actually is an array. Maybe we get only 1 response which shouldnt be an array. Take that into account
    if ([responseObject isKindOfClass:[NSArray class]]) {
        // responseObject contains an Array, which would mean that we are recieving eligable groups for example.
        for (NSDictionary *diction in receivedGroups) {
            
            IRGroup *group = [[IRGroup alloc] initWithGroupId:[[diction objectForKey:@"_id"] integerValue]
                                                     imageUrl:[diction objectForKey:@"image"]
                                                       gender:[[diction objectForKey:@"gender"] integerValue]
                                                          age:[[diction objectForKey:@"age"] integerValue]
                                                     distance:[[diction objectForKey:@"distance_km"] integerValue]];
            // Add the group to groups array
            [groups addObject:group];
        }
        
    } else {
        // responseObject is an dictionary, which means that we probably received an matched group
        IRGroup *group = [[IRGroup alloc] initWithGroupId:[[responseObject objectForKey:@"_id"] integerValue]
                                                 imageUrl:[responseObject objectForKey:@"image"]
                                                   gender:[[responseObject objectForKey:@"gender"] integerValue]
                                                      age:[[responseObject objectForKey:@"age"] integerValue]
                                                 distance:[[responseObject objectForKey:@"distance_km"] integerValue]];
        // Add the group to groups array
        [groups addObject:group];
    }
    return groups;
}



@end
