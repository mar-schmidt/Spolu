//
//  MRInstallation.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-12.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "MRInstallation.h"

@implementation MRInstallation

+ (MRInstallation *)currentInstallation
{
    static MRInstallation *_currentInstallation = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _currentInstallation = [[self alloc] init];
    });
    
    return _currentInstallation;
}

- (void)saveInBackground
{
    if (_deviceTokenFromData) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        parameters[@"token"] = _deviceTokenFromData;
        
        // Print the device token to log for debug
        NSString* deviceToken = [[[[_deviceTokenFromData description]
                                    stringByReplacingOccurrencesOfString: @"<" withString: @""]
                                   stringByReplacingOccurrencesOfString: @">" withString: @""]
                                  stringByReplacingOccurrencesOfString: @" " withString: @""];
        
        NSLog(@"Device Token: %@",deviceToken);
        
        /*[self POST:@"https://spolu.herokuapp.com/registerDevice"
        parameters:_deviceTokenFromData
           success:^(NSURLSessionDataTask *task, id responseObject) {
               NSLog(@"Device Token successfully registered with the backend");
           }
           failure:^(NSURLSessionDataTask *task, NSError *error) {
               NSLog(@"Failed registering device token with the backend");
           }];
         */
    }
}

@end
