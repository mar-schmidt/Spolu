//
//  IROwnGroup.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-25.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRGroup.h"

@interface IROwnGroup : IRGroup

+ (id)sharedGroup;

@property (nonatomic) NSInteger *groupId;

@end
