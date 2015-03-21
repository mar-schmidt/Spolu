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
        
        IRMatchedGroupsDataSourceManager *matchedGroupsDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
        
        // Check if local matchedGroup datasource actually exist and contains groups. If not, fetch from backend
        NSLog(@"Checking if we do have a local datasource of matched groups...");
        if (matchedGroupsDataSourceManager.groupConversationsDataSource &&
            matchedGroupsDataSourceManager.groupConversationsDataSource.count > 0) {
            NSLog(@"Local datasource of matched groups was found. Adding the newly matched group to it");
            // Get our newly matched group from backend and send a notification about it.
            [self getRecentMatchFromBackendWithGroupId:groupId
                                andWithCompletionBlock:^(IRGroup *group) {
                                    NSLog(@"Newly matched group retrieved from backend. Notifying rest of the application...");
                                    // Create a conversation for this group and notify rest of the app
                                    IRGroupConversation *newGroupConversation = [matchedGroupsDataSourceManager createNewGroupConversationWithMessage:nil fromGroup:group];
                                    [self sendNotificationAboutMatchWithGroup:newGroupConversation];
                                }];
        } else {
            // So locally matchedGroup datasource doesnt exist or does not have any matches in it. Start fetching from backend
            NSLog(@"No local datasource of matched groups found. Fetching total list of matched groups from backend...");
            [self currentMatchesFromBackendWithCompletionBlock:^(NSArray *groups) {
                // Allright, so we got our new list of matches. Should contain our newly match. Get it and notify about newly match. But first. Set it as our matched datasource
                NSLog(@"Total list of matched retrieved from backend. Enumerating through it and grab the newly matched group...");
                NSMutableArray *newlyReceivedMatchingGroupConversations = [groups mutableCopy];
                matchedGroupsDataSourceManager.groupConversationsDataSource = newlyReceivedMatchingGroupConversations;
                for (IRGroupConversation *groupConversation in newlyReceivedMatchingGroupConversations) {
                    if (groupConversation.group.groupId == groupId) {
                        NSLog(@"Newly matched group was grabbed. Notifying rest of the application...");
                        [self sendNotificationAboutMatchWithGroup:groupConversation];
                    }
                }
            }];
        }
        
        
        
        
        /*
        
        // Create group from this push-match
        [self groupFromMatchPush:userInfo withCompletionGroup:^(IRGroup *match) {
            // Check matchedGroups array for this group, if it doesnt exists, we'll add it to matchedGroups
            IRMatchedGroups *matchedGroups = [IRMatchedGroups sharedMatchedGroups];
            NSMutableArray *matchedGroupsArrayCopy = [matchedGroups.groups copy];
            if (matchedGroupsArrayCopy && matchedGroupsArrayCopy.count > 0) {
                // Previous matches exist. Check if this match exists.
                for (IRGroup *group in matchedGroupsArrayCopy) {
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
         */
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

+ (void)sendNotificationAboutMatchWithGroup:(IRGroupConversation *)groupConversation
{
    NSDictionary *userInfo = @{@"group" : groupConversation,
                               @"channel" : groupConversation.conversationChannel};
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:@"newMatchReceived" object:self userInfo:userInfo];
}
/*
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
*/
+ (void)currentMatchesFromBackendWithCompletionBlock:(void (^)(NSArray *groupConversations))matchedGroupConversations
{
    NSLog(@"Fetching current matches from backend...");
    IRMatchServiceHandler *matchServiceHandler = [IRMatchServiceHandler sharedMatchServiceHandler];
    IRMatchedGroupsDataSourceManager *matchedGroupsDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
    
    [matchServiceHandler getMatchesConversationsWithCompletionBlock:^(NSArray *groupConversations) {
        NSLog(@"Received %ld matches", (long)groupConversations.count);

        matchedGroupConversations(groupConversations);

    } failure:^(NSError *error) {
        NSLog(@"Failed retrieving matches. %@", error.localizedDescription);
    }];
    
    /*
    [matchServiceHandler getMatchesWithCompletionBlock:^(NSArray *groups) {
            } failure:^(NSError *error) {
     
    }];
     */
}

+ (void)getRecentMatchFromBackendWithGroupId:(NSInteger)groupId andWithCompletionBlock:(void (^)(IRGroup *group))matchedGroup
{
    NSLog(@"Fetching recent match from backend...");
    IRMatchServiceHandler *matchServiceHandler = [IRMatchServiceHandler sharedMatchServiceHandler];
    [matchServiceHandler getRecentMatchWithGroupId:groupId
                                andCompletionBlock:^(IRGroup *group) {
                                    matchedGroup(group);
                                } failure:^(NSError *error) {
                                    NSLog(@"Failed retrieving newly matched group. %@", error.localizedDescription);
                                }];
}
@end


















