//
//  IRGroup.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-24.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRGroup.h"
#import "SDWebImageManager.h"

@implementation IRGroup


- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (id)initWithGroupId:(NSInteger)groupId imageUrl:(NSString *)imageUrl gender:(NSInteger)genderInt age:(NSInteger)age distance:(NSInteger)distanceInKm name:(NSString *)name
{
    self = [super init];
    if (self) {
        _groupId = groupId;
        _imageUrl = imageUrl;
        _genderInt = genderInt;
        _age = age;
        _distance = distanceInKm;
        _name = name;
        
        // Download image
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSLog(@"Starting downloading image for group %ld", (long)_groupId);
        [manager downloadImageWithURL:[NSURL URLWithString:imageUrl]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (image) {
                 _downloadedImage = image;
                 NSLog(@"Downloaded image completed for group %ld", (long)_groupId);
             }
         }];
    }
    return self;
}

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
                      imageUrl:(NSString *)imageUrl
{
    self = [super init];
    if (self) {
        _genderInt = genderInt;
        _lookingForGenderInt = lookingGenderInt;
        _age = years;
        _lookingForAgeLower = lower;
        _lookingForAgeUpper = upper;
        _locationLat = latitude;
        _locationLong = longitude;
        _lookingForInAreaWithDistanceInKm = km;
        _name = name;
        _groupId = groupId;
        _imageUrl = imageUrl;
        
        // Download image
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        NSLog(@"Starting downloading image for group %ld", (long)_groupId);
        [manager downloadImageWithURL:[NSURL URLWithString:imageUrl]
                              options:0
                             progress:^(NSInteger receivedSize, NSInteger expectedSize)
         {
             // progression tracking code
         }
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
         {
             if (image) {
                 // do something with image
                 _downloadedImage = image;
                 NSLog(@"Downloaded image completed for group %ld", (long)_groupId);
             }
         }];
    }
    return self;
}

- (IRGroup *)randomGroupWithId:(NSInteger)gId
{
    IRGroup *group = [[IRGroup alloc] init];
    
    group.groupId = gId;
    group.imageUrl = [self imageUrlStringFromNumber:group.groupId];
    

    // Download image
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSLog(@"Starting downloading image for group %ld", (long)group.groupId);
    [manager downloadImageWithURL:[NSURL URLWithString:group.imageUrl]
                          options:0
                         progress:^(NSInteger receivedSize, NSInteger expectedSize)
     {
         // progression tracking code
     }
                        completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
     {
         if (image) {
             // do something with image
             NSLog(@"Downloaded image completed for group %ld", (long)group.groupId);
             group.downloadedImage = image;
         }
     }];

    
    // Randomize gender
    GenderType randomGender = (GenderType) (arc4random() % (int) 2);
    GenderType randomGenderLookingFor = (GenderType) (arc4random() % (int) 2);
    group.gender = randomGender;
    group.lookingForGender = randomGenderLookingFor;
    
    group.age = (arc4random()%(50-18))+18;
    group.lookingForAgeLower = (arc4random()%(50-18))+18;
    group.lookingForAgeUpper = (arc4random()%(50-18))+18;
    group.lookingForInAreaWithDistanceInKm = arc4random()%100;
    
    group.token = [NSString stringWithFormat:@"%ld", arc4random()%555598712379361];
    
    return group;
}

- (NSString *)imageUrlStringFromNumber:(NSInteger)imageNumber
{
    NSString *randomImageString = [[NSString alloc] init];
    
    switch (imageNumber) {
        case 1:
            randomImageString = @"http://3.bp.blogspot.com/-2bS7s_58AN8/U5QqhnoSuYI/AAAAAAAAA1M/Gm7PXvMm7Wk/s1600/IMG-20140529-WA0020.jpg";
            break;
        case 2:
            randomImageString = @"http://i1.mirror.co.uk/incoming/article3036092.ece/alternates/s615/The-Kardashian-ladies-pose-for-group-selfie-at-Eagles-gig.jpg";
            break;
        case 3:
            randomImageString = @"http://images.scribblelive.com/2014/1/21/37087f85-fb99-4cf3-8661-0fad9b71bc4b_500.jpg";
            break;
        case 4:
            randomImageString = @"http://d7.freedomworks.org.s3.amazonaws.com/field/image/group%20selfie.jpeg";
            break;
        case 5:
            randomImageString = @"http://www.colorado.edu/umc/sites/default/files/page/BOARD-GROUP-SELFIE-960X640.jpg";
            break;
        case 6:
            randomImageString = @"http://outoftownblog.com/wp-content/uploads/2014/03/Group-Selfie-Shot-ontop-of-Poro-Point-Lighthouse-600x450.jpg";
            break;
        case 7:
            randomImageString = @"http://spectrum.ph/wp-content/uploads/2014/05/selfie-group.jpg";
            break;
    }
    return randomImageString;
}






























































@end
