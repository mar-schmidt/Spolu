//
//  IRMatchServiceHandler.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRMatchServiceHandler.h"
#import "EligibleGroupsDataSource.h"

// Api key and address
static NSString * const ApiKey = @"ASDJOO12893891JAHDS";
//static NSString * const ApiAddress = @"https://spolu.herokuapp.com";
static NSString * const ApiAddress = @"http://192.168.1.137:3000";

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
        
        // Set EligibleGroupsDataSource as delegate. That class will hold on to all the groups currenctly available
        EligibleGroupsDataSource *dataSource = [EligibleGroupsDataSource sharedEligibleGroupsDataSource];
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

- (void)getMatchesConversationsWithCompletionBlock:(void (^)(NSArray *groupConversations))matchedGroupConversations failure:(void (^)(NSError *error))failure
{
    // API request
    [self GET:[NSString stringWithFormat:@"%@/matches", ApiAddress]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          // Parse dictionary responseObject to group object
          NSMutableArray *groups = [jsonParser parseGroupsFromResponseObject:responseObject];
          NSMutableArray *groupConversations = [[NSMutableArray alloc] init];
          for (IRGroup *group in groups) {
              IRGroupConversation *newGroupConversation = [[IRGroupConversation alloc] init];
              newGroupConversation.group = group;
              newGroupConversation.conversationChannel = group.channel;
              
              [groupConversations addObject:newGroupConversation];
          }
          matchedGroupConversations(groupConversations);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
              [self.delegate matchServiceHandler:self didFailWithError:error];
          }
      }];
}

- (void)getRecentMatchWithGroupId:(NSInteger)groupId andCompletionBlock:(void (^)(IRGroup *))matchedGroup failure:(void (^)(NSError *))failure
{
    // API request
    [self GET:[NSString stringWithFormat:@"%@/users/%ld", ApiAddress, (long)groupId]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          // Parse dictionary responseObject to group object
          NSMutableArray *groups = [jsonParser parseGroupsFromResponseObject:responseObject];
          for (IRGroup *group in groups) {
              matchedGroup(group);
          }
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

- (void)postMyGroup:(IRGroup *)group withBase64Image:(NSString *)base64Image andCompletionBlockSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    NSMutableDictionary *picFileDict = [NSMutableDictionary dictionary];
    
    picFileDict[@"file"] = base64Image;
    picFileDict[@"original_filename"] = @"bajs";
    picFileDict[@"filename"] = @"KNUUULLA CARLOS";
    
    /*
     {
         "id": 1,
         "latitude": 12,
         "longitude": 57.6870556,
         "gender": 0,
         "looking_for_gender": 1,
         "age": 22,
         "distance": 20,
         "looking_for_upper_age": 30,
         "looking_for_lower_age": 20,
         "picture_path": {
             "file": "BASE64skit",
             "original_filename": "my file name",
             "filename": "my file name"
         }
     }
     */
    
    // Parameters that are sent to API
    parameters[@"gender"] = [NSString stringWithFormat:@"%ld", (long)group.genderInt];
    parameters[@"looking_for_gender"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForGenderInt];
    parameters[@"age"] = [NSString stringWithFormat:@"%ld", (long)group.age];
    parameters[@"looking_for_lower_age"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForAgeLower];
    parameters[@"looking_for_upper_age"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForAgeUpper];
    parameters[@"latitude"] = [NSString stringWithFormat:@"%ld", (long)group.locationLat];
    parameters[@"longitude"] = [NSString stringWithFormat:@"%ld", (long)group.locationLong];
    parameters[@"distance"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForInAreaWithDistanceInKm];
    parameters[@"picture_path"] = picFileDict;
    
    [self POST:[NSString stringWithFormat:@"%@/users", ApiAddress]
    parameters:parameters
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSInteger ourGroupId = [[responseObject objectForKey:@"_id"] integerValue];
           if (ourGroupId) {
               NSLog(@"Successfully added our group to backend with id %ld", (long)ourGroupId);
               /*
               IROwnGroup *ownGroup = [IROwnGroup sharedGroup];
               ownGroup.group = group;
               success(YES);
                */
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
              group.match = YES;
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































