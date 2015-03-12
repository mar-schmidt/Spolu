//
//  MRInstallation.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-12.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface MRInstallation : AFHTTPSessionManager

@property (nonatomic, strong) NSData *deviceTokenFromData;

+ (MRInstallation *)currentInstallation;
- (void)saveInBackground;

@end
