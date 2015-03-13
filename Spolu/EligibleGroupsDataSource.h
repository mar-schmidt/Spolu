//
//  IRMatchServiceDataSource.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-10.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRMatchServiceHandler.h"
#import "IRGroup.h"

@protocol EligibleGroupsDataSourceDelegate;

@interface EligibleGroupsDataSource : NSObject <IRMatchServiceHandlerDelegate>


@property (nonatomic, strong) id<EligibleGroupsDataSourceDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *dataSource;

+ (EligibleGroupsDataSource *)sharedEligibleGroupsDataSource;

@end

@protocol EligibleGroupsDataSourceDelegate <NSObject>
@optional

- (void)eligibleGroupsDataSource:(EligibleGroupsDataSource *)dataSource didReceiveEligibleGroups:(NSMutableArray *)groups;
- (void)eligibleGroupsDataSource:(EligibleGroupsDataSource *)dataSource didReceiveMatchWithGroup:(IRGroup *)group;

- (void)eligibleGroupsDataSource:(EligibleGroupsDataSource *)dataSource
      downloadingImageForGroup:(IRGroup *)group
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
         downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock;;

// Error
- (void)eligibleGroupsDataSource:(EligibleGroupsDataSource *)dataSource didFailWithError:(NSError *)error;
@end
