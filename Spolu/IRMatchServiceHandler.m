//
//  IRMatchServiceHandler.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRMatchServiceHandler.h"
#import "EligibleGroupsDataSource.h"
#import "MRInstallation.h"

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
        MRInstallation *installation = [MRInstallation currentInstallation];
        
        // Set the headers
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [self.requestSerializer setValue:[NSString stringWithFormat:@"Token token=%@", installation.deviceToken] forHTTPHeaderField:@"Authorization"];
        
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
    NSLog(@"GET /nearby from backend...");
    // API request
    [self GET:[NSString stringWithFormat:@"%@/nearby", ApiAddress]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didReceiveEligibleGroups:)]) {
              
              // Parse dictionary responseObject to group object
              NSMutableArray *groups = [jsonParser parseGroupsFromResponseObject:responseObject];
              
              NSLog(@"Got %ld eligible groups from backend...", (long)groups.count);
              
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
    NSLog(@"Check backend if our group exists depending on our auth-token...");
    // API request
    [self GET:[NSString stringWithFormat:@"%@/auth", ApiAddress]
   parameters:nil
      success:^(NSURLSessionDataTask *task, id responseObject) {
          
          if (![responseObject objectForKey:@"error"]) {
              NSInteger genderInt = [[responseObject objectForKey:@"gender"] integerValue];
              NSInteger lookingForGenderInt = [[responseObject objectForKey:@"looking_for_gender"] integerValue];
              NSInteger age = [[responseObject objectForKey:@"age"] integerValue];
              NSInteger lookingForAgeLower = [[responseObject objectForKey:@"looking_for_age_lower"] integerValue];
              NSInteger lookingForAgeUpper = [[responseObject objectForKey:@"looking_for_age_upper"] integerValue];
              double latitude = [[responseObject objectForKey:@"latitude"] doubleValue];
              double longitude = [[responseObject objectForKey:@"longitude"] doubleValue];
              NSInteger distance = [[responseObject objectForKey:@"distance"] integerValue];
              NSString *name = [responseObject objectForKey:@"name"];
              NSInteger groupId = [[responseObject objectForKey:@"_id"] integerValue];
              NSString *imageUrl = [responseObject objectForKey:@"image"];
              
              NSLog(@"Group with id %ld exists in backend. Returning it...", (long)groupId);
              
              
              IRGroup *myNewGroup = [[IRGroup alloc] initWithOwnGroupOfGender:genderInt
                                                             lookingForGender:lookingForGenderInt
                                                                          age:age
                                                           lookingForAgeLower:lookingForAgeLower
                                                           lookingForAgeUpper:lookingForAgeUpper
                                                             locationLatitude:latitude
                                                            locationLongitude:longitude
                                             lookingForInAreaWithDistanceInKm:distance
                                                                         name:name
                                                                          gId:groupId
                                                                     imageUrl:imageUrl];
              
              myGroup(myNewGroup);
          } else {
              NSLog(@"No group exists in backend...");
          }
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

- (void)postMyGroup:(IRGroup *)group withBase64Image:(NSString *)base64Image withDeviceToken:(NSString *)token andCompletionBlockSuccess:(void (^)(BOOL, NSInteger))success failure:(void (^)(NSError *))failure
{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSMutableDictionary *picFileDict = [NSMutableDictionary dictionary];
    
    picFileDict[@"file"] = base64Image;
    picFileDict[@"original_filename"] = @"bajs";
    picFileDict[@"filename"] = @"KNUUULLA CARLOS";
    
    // Parameters that are sent to API
    parameters[@"name"] = group.name;
    parameters[@"gender"] = [NSString stringWithFormat:@"%ld", (long)group.genderInt];
    parameters[@"looking_for_gender"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForGenderInt];
    parameters[@"age"] = [NSString stringWithFormat:@"%ld", (long)group.age];
    parameters[@"looking_for_lower_age"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForAgeLower];
    parameters[@"looking_for_upper_age"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForAgeUpper];
    parameters[@"latitude"] = [NSString stringWithFormat:@"%ld", (long)group.locationLat];
    parameters[@"longitude"] = [NSString stringWithFormat:@"%ld", (long)group.locationLong];
    parameters[@"distance"] = [NSString stringWithFormat:@"%ld", (long)group.lookingForInAreaWithDistanceInKm];
    parameters[@"picture_path"] = picFileDict;
    parameters[@"ios_token"] = token;
    
    [self POST:[NSString stringWithFormat:@"%@/users", ApiAddress]
    parameters:parameters
       success:^(NSURLSessionDataTask *task, id responseObject) {
           NSInteger ourGroupId = [[responseObject objectForKey:@"_id"] integerValue];
           
           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
           [dateFormatter setLocale:[NSLocale currentLocale]];
           [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
           [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
           NSDate *date = [[NSDate alloc] init];
           date = [dateFormatter dateFromString:[responseObject objectForKey:@"expiry_date"]];
           
           NSLog(@"%@", date);
           
           // Store the data
           //NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
           //[defaults setObject:date forKey:@"expiry_date"];
           //[defaults synchronize];
           
           NSLog(@"Data saved");
           
           if (ourGroupId) {
               NSLog(@"Successfully added our group to backend with id %ld", (long)ourGroupId);
               
               success(YES, ourGroupId);
               
           }
       }
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           if ([self.delegate respondsToSelector:@selector(matchServiceHandler:didFailWithError:)]) {
               [self.delegate matchServiceHandler:self didFailWithError:error];
           }
       }];
}

- (void)postLikeForGroup:(IRGroup *)group withCompletionBlockMatch:(void (^)(BOOL, NSString *))match failure:(void (^)(NSError *))failure
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
              group.groupId = [[responseObject objectForKey:@"user_id"] integerValue];
              group.channel = [responseObject objectForKey:@"channel"];
              match(YES, group.channel);
          } else {
              // No match!
              match(NO, nil);
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































