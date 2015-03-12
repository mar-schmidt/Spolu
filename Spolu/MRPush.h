//
//  MRPush.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-12.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MRPush : NSObject

+ (void)handlePush:(NSDictionary *)userInfo;

@end
