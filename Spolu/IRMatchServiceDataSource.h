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

@protocol IRMatchServiceDataSourceDelegate;

@interface IRMatchServiceDataSource : NSObject <IRMatchServiceHandlerDelegate>


@property (nonatomic, strong) id<IRMatchServiceDataSourceDelegate>delegate;
@property (nonatomic, strong) NSMutableArray *dataSource;

+ (IRMatchServiceDataSource *)sharedMatchServiceDataSource;

@end

@protocol IRMatchServiceDataSourceDelegate <NSObject>
@optional

- (void)matchServiceDataSource:(IRMatchServiceDataSource *)dataSource didReceiveEligibleGroups:(NSMutableArray *)groups;
- (void)matchServiceDataSource:(IRMatchServiceDataSource *)dataSource didReceiveMatchWithGroup:(IRGroup *)group;

- (void)matchServiceDataSource:(IRMatchServiceDataSource *)dataSource
      downloadingImageForGroup:(IRGroup *)group
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
         downloadProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))downloadProgressBlock;;

// Error
- (void)matchServiceDataSource:(IRMatchServiceDataSource *)dataSource didFailWithError:(NSError *)error;
@end
