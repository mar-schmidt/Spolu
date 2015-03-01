//
//  IRGroup.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-24.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRGroup.h"

@implementation IRGroup

@synthesize groupId;
@synthesize imageUrl;
@synthesize downloadedImage;
@synthesize genderInt;
@synthesize gender;
@synthesize lookingForGenderInt;
@synthesize lookingForGender;
@synthesize age;
@synthesize lookingForAgeLower;
@synthesize lookingForAgeUpper;
@synthesize locationLat;
@synthesize locationLong;
@synthesize lookingForInAreaWithDistanceInKm;
@synthesize token;

- (id)init
{
    self = [super init];
    if (self) {
        // Set gender depending on genderInt received from backend
        switch (genderInt) {
            case 0: // Males
                gender = IRGenderTypeMales;
                break;
            case 1: // Both
                gender = IRGenderTypeBoth;
                break;
            case 2: // Females
                gender = IRGenderTypeFemales;
                break;
                
            default: // Default both if backend's not sending correct value
                gender = IRGenderTypeBoth;
                break;
        }
        
        // Set lookingForGender depending on lookingForGenderInt received from backend
        switch (lookingForGenderInt) {
            case 0: // Males
                lookingForGender = IRGenderTypeMales;
                break;
            case 1: // Both
                lookingForGender = IRGenderTypeBoth;
                break;
            case 2: // Females
                lookingForGender = IRGenderTypeFemales;
                break;
                
            default: // Default both if backend's not sending correct value
                lookingForGender = IRGenderTypeBoth;
                break;
        }
    }
    return self;
}


- (IRGroup *)randomGroup
{
    IRGroup *group = [[IRGroup alloc] init];
    
    group.groupId = arc4random()%5555;
    group.imageUrl = @"http://lorempixel.com/400/400/people/";
    group.downloadingImageView = [[UIImageView alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:group.imageUrl]];
    [group.downloadingImageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        group.downloadedImage = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
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






























































@end
