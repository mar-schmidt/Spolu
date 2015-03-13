//
//  IRMatchServiceHandler.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "IRGroup.h"
#import "IRJsonToGroupParser.h"
#import "IRMatchedGroups.h"
#import "IROwnGroup.h"

@protocol IRMatchServiceHandlerDelegate;

@interface IRMatchServiceHandler : AFHTTPSessionManager
{
    IRJsonToGroupParser *jsonParser;
}
@property (nonatomic, strong) id<IRMatchServiceHandlerDelegate>delegate;

+ (IRMatchServiceHandler *)sharedMatchServiceHandler;
- (instancetype)initWithBaseURL:(NSURL *)url;

// Post
- (void)postMyGroup:(IRGroup *)group withCompletionBlockSuccess:(void (^)(BOOL succeeded))success failure:(void (^)(NSError *error))failure;
- (void)postUpdateForMyGroup:(IRGroup *)group withCompletionBlockSuccess:(void (^)(BOOL succeeded))success failure:(void (^)(NSError *error))failure;
- (void)postLikeForGroup:(IRGroup *)group withCompletionBlockMatch:(void (^)(BOOL matching))match failure:(void (^)(NSError *error))failure;
- (void)postPassForGroup:(IRGroup *)group withCompletionBlockSuccess:(void (^)(BOOL succeeded))success failure:(void (^)(NSError *error))failure;

// Get
- (void)getEligibleGroupsResultForGroup:(IRGroup *)group;
- (void)getMyGroupWithCompletionBlockSuccess:(void (^)(IRGroup *group))myGroup failure:(void (^)(NSError *error))failure;
- (void)getMatchesWithCompletionBlock:(void (^)(NSArray *groups))matchedGroups failure:(void (^)(NSError *error))failure;
- (void)getRecentMatchWithGroupId:(NSInteger)groupId andCompletionBlock:(void (^)(IRGroup *group))matchedGroup failure:(void (^)(NSError *error))failure;


@end

@protocol IRMatchServiceHandlerDelegate <NSObject>
@optional

- (void)matchServiceHandler:(IRMatchServiceHandler *)service didReceiveEligibleGroups:(NSMutableArray *)groups;
- (void)matchServiceHandler:(IRMatchServiceHandler *)service didReceiveMatchWithGroup:(IRGroup *)group;

// Error
- (void)matchServiceHandler:(IRMatchServiceHandler *)service didFailWithError:(NSError *)error;
@end
