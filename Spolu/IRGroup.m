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


- (IRGroup *)randomGroupWithId:(NSInteger)gId
{
    IRGroup *group = [[IRGroup alloc] init];
    
    group.groupId = gId;
    group.imageUrl = [self imageUrlStringFromNumber:group.groupId];
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
