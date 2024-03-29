//
//  IRGroup.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-24.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIImageView+AFNetworking.h"

typedef enum {
    IRGenderTypeMales    = 0,
    IRGenderTypeBoth     = 1,
    IRGenderTypeFemales  = 2
} GenderType;

@interface IRGroup : NSObject
{
    NSInteger distanceTo;
}

@property (nonatomic) NSInteger groupId;
@property (nonatomic, retain) NSString *imageUrl;
@property (nonatomic, retain) UIImage *downloadedImage;
@property (nonatomic, retain) UIImageView *downloadingImageView;
@property (nonatomic) NSInteger genderInt;
@property (nonatomic) GenderType gender;
@property (nonatomic) NSInteger lookingForGenderInt;
@property (nonatomic) GenderType lookingForGender;
@property (nonatomic) NSInteger age;
@property (nonatomic) NSInteger lookingForAgeLower;
@property (nonatomic) NSInteger lookingForAgeUpper;
@property (nonatomic) double locationLat;
@property (nonatomic) double locationLong;
@property (nonatomic) NSInteger lookingForInAreaWithDistanceInKm;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, strong) IRGroup *localGroup;
@property (nonatomic) NSInteger distance;
@property (nonatomic) BOOL match;
@property (nonatomic, strong) NSString *channel;
@property (nonatomic, strong) NSString *name;

- (id)initWithGroupId:(NSInteger)groupId
             imageUrl:(NSString *)imageUrl
               gender:(NSInteger)genderInt
                  age:(NSInteger)age
             distance:(NSInteger)distanceInKm
                 name:(NSString *)name;

- (id)initWithOwnGroupOfGender:(NSInteger)genderInt
              lookingForGender:(NSInteger)lookingGenderInt
                           age:(NSInteger)years
            lookingForAgeLower:(NSInteger)lower
            lookingForAgeUpper:(NSInteger)upper
              locationLatitude:(double)latitude
             locationLongitude:(double)longitude
lookingForInAreaWithDistanceInKm:(NSInteger)km
                          name:(NSString *)name
                            gId:(NSInteger)groupId
                      imageUrl:(NSString *)imageUrl;

- (IRGroup *)randomGroupWithId:(NSInteger)gId;

@end
