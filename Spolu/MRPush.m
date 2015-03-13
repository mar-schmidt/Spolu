//
//  MRPush.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-12.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "MRPush.h"

@implementation MRPush

+ (void)handlePush:(NSDictionary *)userInfo
{
    NSInteger pushCode = [userInfo[@"push_Code"] integerValue];
    NSInteger groupId = [userInfo[@"id"] integerValue];
    NSDictionary *aps = userInfo[@"aps"];
    NSString *alertMessage = aps[@"alert"];
    
    if (pushCode == 1) { // pushCode 1 = New match
        NSLog(@"Push Notification received: %@ from group %ld", alertMessage, (long)groupId);
        
        // Create group from this push-match
        [self groupFromMatchPush:userInfo withCompletionGroup:^(IRGroup *match) {
            // Check matchedGroups array for this group, if it doesnt exists, we'll add it to matchedGroups
            IRMatchedGroups *matchedGroups = [IRMatchedGroups sharedMatchedGroups];
            if (matchedGroups.groups && matchedGroups.groups.count > 0) {
                // Previous matches exist. Check if this match exists.
                for (IRGroup *group in matchedGroups.groups) {
                    if (match.groupId == group.groupId) {
                        // Received push-match-group already exists matchedGroups.group array, then we wont need to do anything.
                    } else {
                        // Allright, received push-match-group does not exists. Then we'll add it and notify about it
                        [matchedGroups.groups addObject:match];
                        [self sendNotificationAboutMatchWithGroup:match];
                    }
                }
            } else {
                // No previus matches exist in matchedGroup. Adding this one
                [matchedGroups.groups addObject:match];
                [self sendNotificationAboutMatchWithGroup:match];
            }
        }];
    }
    else if (pushCode == 2) { // Common announcement
        
    }
    else if (pushCode == 3) {
        
    }
    else if (pushCode == 4) {
        
    }
    else if (pushCode == 5) {
        
    }

}

+ (void)sendNotificationAboutMatchWithGroup:(IRGroup *)group
{
    NSDictionary *userInfo = @{@"group" : group};
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"newMatchReceived" object:self userInfo:userInfo];
}

+ (void)groupFromMatchPush:(NSDictionary *)userInfo withCompletionGroup:(void(^)(IRGroup *match))matchedGroup
{
    // Get the current matches, the new match should be included here. We'll need to find it
    [self currentMatchesFromBackendWithCompletionBlock:^(NSArray *groups) {
        // First we'll need the group id to find the push-match-group within the total array of matches
        NSInteger groupId = [userInfo[@"id"] integerValue];
        for (IRGroup *group in groups) {
            if (group.groupId == groupId) {
                matchedGroup(group);
                break;
            }
        }
    }];
}

+ (void)currentMatchesFromBackendWithCompletionBlock:(void (^)(NSArray *groups))matchedGroups
{
    NSLog(@"Fetching current matches from backend...");
    IRMatchServiceHandler *matchServiceHandler = [IRMatchServiceHandler sharedMatchServiceHandler];
    [matchServiceHandler getMatchesWithCompletionBlock:^(NSArray *groups) {
        NSLog(@"Received %ld matches", (long)groups.count);
        matchedGroups(groups);
    } failure:^(NSError *error) {
        NSLog(@"Failed retrieving matches. %@", error.localizedDescription);
    }];
}

@end
