//
//  IRMatchServiceHandler.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRMatchServiceHandler.h"
#import "IRMatchServiceDataSource.h"

// Api key and address
static NSString * const ApiKey = @"ASDJOO12893891JAHDS";
static NSString * const ApiAddress = @"https://spolu.herokuapp.com";

@implementation IRMatchServiceHandler

+ (IRMatchServiceHandler *)sharedMatchServiceHandler
{
    static IRMatchServiceHandler *_sharedMatchServiceHandler = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMatchServiceHandler = [[self alloc] initWithBaseURL:[NSURL URLWithString:ApiAddress]];
    });
    
    return _sharedMatchServiceHandler;
}

- (instancetype)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        jsonParser = [IRJsonToGroupParser sharedIRJsonToGroupParser];
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        
        // Set the headers
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        //[self.requestSerializer setValue:FathomelessApiKey forHTTPHeaderField:@"Authorization"];
        //[self.requestSerializer setValue:[NSString stringWithFormat:@"Token token=%@", ApiKey] forHTTPHeaderField:@"Authorization"];
        
        // Set IRMatchServiceDataSource as delegate. That class will hold on to all the groups currenctly available
        IRMatchServiceDataSource *dataSource = [IRMatchServiceDataSource sharedMatchServiceDataSource];
        _delegate = dataSource;
    }
    
    return self;
}

/******
*
* Get methods
*
******/

- (void)getEligibleGroupsResultForGroup:(IRGroup *)group
{
    // API request
    [self GET:[NSString stringWithFormat:@"%@/nearby", ApiAddress]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didReceiveEligibleGroups:)]) {
              
              // Parse dictionary responseObject to group object
              NSMutableArray *groups = [jsonParser parseGroupsFromResponseObject:responseObject];
              
              [self.delegate matchServiceHandler:self didReceiveEligibleGroups:groups];
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
              [self.delegate matchServiceHandler:self didFailWithError:error];
          }
      }];
}

- (void)getMyGroupWithCompletionBlockSuccess:(void (^)(IRGroup *))myGroup failure:(void (^)(NSError *))failure
{
    // API request
    [self GET:[NSString stringWithFormat:@"%@/groups/mygroup", ApiAddress]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          
          NSInteger groupId = [[responseObject objectForKey:@"_id"] integerValue];
          NSString *imageUrl = [responseObject objectForKey:@"image"];
          NSInteger genderInt = [[responseObject objectForKey:@"gender"] integerValue];
          NSInteger age = [[responseObject objectForKey:@"age"] integerValue];
          
          IRGroup *myNewGroup = [[IRGroup alloc] initWithGroupId:groupId
                                                        imageUrl:imageUrl
                                                          gender:genderInt
                                                             age:age
                                                        distance:0];
          
          myGroup(myNewGroup);
          
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
              [self.delegate matchServiceHandler:self didFailWithError:error];
          }
      }];
}

- (void)getMatchesWithCompletionBlock:(void (^)(NSArray *))matchedGroups failure:(void (^)(NSError *))failure
{
    // API request
    [self GET:[NSString stringWithFormat:@"%@/matches", ApiAddress]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          // Parse dictionary responseObject to group object
          NSMutableArray *groups = [jsonParser parseGroupsFromResponseObject:responseObject];
          matchedGroups(groups);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
              [self.delegate matchServiceHandler:self didFailWithError:error];
          }
      }];
}


/******
 *
 * Post methods
 *
 ******/

- (void)postMyGroup:(IRGroup *)group withCompletionBlockSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // Parameters that are sent to API
    parameters[@"genderInt"] = [NSString stringWithFormat:@"%ld", (long)group.genderInt];
    parameters[@"lookingForGenderInt"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForGenderInt];
    parameters[@"age"] = [NSString stringWithFormat:@"%ld", (long)group.age];
    parameters[@"lookingForAgeLower"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForAgeLower];
    parameters[@"lookingForAgeUpper"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForAgeUpper];
    parameters[@"locationLatitude"] = [NSString stringWithFormat:@"%ld", (long)group.locationLat];
    parameters[@"locationLongitude"] = [NSString stringWithFormat:@"%ld", (long)group.locationLong];
    parameters[@"lookingForAreaWithDistanceInKm"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForInAreaWithDistanceInKm];
    
    [self POST:[NSString stringWithFormat:@"%@/add/group", ApiAddress]
    parameters:parameters
       success:^(NSURLSessionDataTask *task, id responseObject) {
           BOOL successFullyAdded = [[responseObject objectForKey:@"success"] boolValue];
           if (successFullyAdded) {
               IROwnGroup *ownGroup = [IROwnGroup sharedGroup];
               ownGroup.group = group;
               success(YES);
           }
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
               [self.delegate matchServiceHandler:self didFailWithError:error];
           }
       }];
}

- (void)postLikeForGroup:(IRGroup *)group withCompletionBlockMatch:(void (^)(BOOL))match failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // Parameters that are sent to API
    parameters[@"id"] = [NSString stringWithFormat:@"%ld", (long)group.groupId];
    
    // API request
    [self POST:[NSString stringWithFormat:@"%@/like", ApiAddress]
   parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          
          BOOL matched = [[responseObject objectForKey:@"match"] boolValue];
          if (matched == YES) {
              // We got ourselves a match. Update group object, add it to IRMatchedGroups and notify completionblock with yes
              group.match = YES;
              
              IRMatchedGroups *matchedGroups = [IRMatchedGroups sharedMatchedGroups];
              if (![matchedGroups.groups containsObject:group]) {
                  [matchedGroups.groups addObject:group];
              }
              
              match(YES);
          } else {
              // No match!
              match(NO);
          }
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
              [self.delegate matchServiceHandler:self didFailWithError:error];
          }
      }];
}

- (void)postPassForGroup:(IRGroup *)group withCompletionBlockSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    // Parameters that are sent to API
    parameters[@"id"] = [NSString stringWithFormat:@"%ld", (long)group.groupId];
    
    // API request
    [self POST:[NSString stringWithFormat:@"%@/pass", ApiAddress]
   parameters:parameters
      success:^(NSURLSessionDataTask *task, id responseObject) {
          // Pass on this group was successfully sent to backend. Update object with no match and notify completionBlock that we successfully passed on this group
          group.match = NO;
          success(YES);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          success(NO);
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
              [self.delegate matchServiceHandler:self didFailWithError:error];
          }
      }];
}

@end































