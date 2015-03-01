//
//  IROwnGroup.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-25.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IROwnGroup.h"

@implementation IROwnGroup

+ (id)sharedGroup {
    static IRGroup *sharedIRGroup = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedIRGroup = [[self alloc] init];
    });
    
    return sharedIRGroup;
}

- (id)init
{
    self = [super init];
    if (self) {
        // This is temporary, IROwnGroup singelton props should be set earlier in filtering section
        if (!self.imageUrl) {
            self.imageUrl = @"http://1.bp.blogspot.com/-kDNQy7tDriY/U6cpcnboZXI/AAAAAAAAI08/lWEmI_JQafQ/s1600/miss-tampa-bay-usa-seminar-weekend-1.png";
            self.gender = IRGenderTypeMales;
            self.lookingForGender = IRGenderTypeFemales;
            self.age = 26;
            self.lookingForAgeLower = 20;
            self.lookingForAgeUpper = 30;
            self.locationLat = 1234;
            self.locationLong = 1234;
            self.lookingForInAreaWithDistanceInKm = 40;
        }
    }
    return self;
}

@end
