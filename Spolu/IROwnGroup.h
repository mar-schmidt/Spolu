//
//  IROwnGroup.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-25.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRGroup.h"
#import "IRMatchServiceHandler.h"

@interface IROwnGroup : IRGroup

@property (nonatomic, strong) IRGroup *group;

+ (id)sharedGroup;

@end
