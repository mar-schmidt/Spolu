//
//  InteractionsChatModel.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "InteractionsChatModel.h"
#import "IRMessage.h"
#import "IRMessageFrame.h"
#import "IRGroup.h"

@implementation InteractionsChatModel

- (id)init {
    if (self = [super init]) {
        ownGroup = [IROwnGroup sharedGroup];
        
        // This is temporary, IROwnGroup singelton props should be set earlier in filtering section
        if (!ownGroup.imageUrl) {
            ownGroup.imageUrl = @"http://1.bp.blogspot.com/-kDNQy7tDriY/U6cpcnboZXI/AAAAAAAAI08/lWEmI_JQafQ/s1600/miss-tampa-bay-usa-seminar-weekend-1.png";
            ownGroup.gender = IRGenderTypeMales;
            ownGroup.lookingForGender = IRGenderTypeFemales;
            ownGroup.age = 26;
            ownGroup.lookingForAgeLower = 20;
            ownGroup.lookingForAgeUpper = 30;
            ownGroup.locationLat = 1234;
            ownGroup.locationLong = 1234;
            ownGroup.lookingForInAreaWithDistanceInKm = 40;
        }
        
        matchedGroups = [IRMatchedGroups sharedMatchedGroups];
    }
    return self;
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

/*
- (void)populateRandomDataSource {
    self.dataSource = [NSMutableArray array];
    NSArray *messageArray = @[[self randomMessage], [self randomMessage], [self randomMessage]];
    [self.dataSource addObjectsFromArray:[self receivedMessages:messageArray fromMatchedGroup:matchedGroups.groups[1]]];
}

- (void)addRandomItemsToDataSource:(NSInteger)number {
    
    for (int i=0; i<number; i++) {
        
        NSArray *messageArray = @[[self randomMessage]];
        
        [self.dataSource insertObject:[[self receivedMessages:messageArray fromMatchedGroup:matchedGroups.groups[1]] firstObject] atIndex:0];
    }
}
*/

// This referes to message from me
- (void)sendMessage:(IRMessage *)message
{
    IRMessageFrame *messageFrame = [[IRMessageFrame alloc] init];
    message.from = IRMessageFromMe;
    message.strTime = [self currentTime];
    message.strIcon = ownGroup.imageUrl;
    [message minuteOffSetStart:previousTime end:[self currentTime]];
    messageFrame.showTime = message.showDateLabel;
    [messageFrame setMessage:message];
    
    if (message.showDateLabel) {
        previousTime = [[NSDate date] description];
    }
    [self.dataSource addObject:messageFrame];
}

- (NSString *)currentTime
{
    //Get current time
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSInteger hour = [dateComponents hour];
    NSString *am_OR_pm=@"AM";
    
    if (hour>12)
    {
        hour=hour%12;
        
        am_OR_pm = @"PM";
    }
    
    NSInteger minute = [dateComponents minute];
    NSInteger second = [dateComponents second];
    
    NSString *currentTime = [NSString stringWithFormat:@"%02ld:%02ld:%02ld %@", (long)hour, (long)minute, (long)second,am_OR_pm];
    
    return currentTime;
}

static NSString *previousTime = nil;


- (NSArray *)receivedMessages:(NSArray *)messages fromMatchedGroup:(IRGroup *)group
{
    // Prod
    NSMutableArray *result = [NSMutableArray array];
    
    for (IRMessage *message in messages) {
        IRMessageFrame *messageFrame = [[IRMessageFrame alloc] init];
        [message minuteOffSetStart:previousTime end:[self currentTime]];
        messageFrame.showTime = message.showDateLabel;
        [messageFrame setMessage:message];
        message.from = IRMessageFromOther;
        message.strTime = [self currentTime];
        
        [result addObject:messageFrame];
    }
    [self.dataSource addObjectsFromArray:result];
    
    return result;
}


static int dateNum = 10;

- (IRMessage *)randomMessage
{
    IRMessage *message = [[IRMessage alloc] init];
    int randomNum = arc4random()%2;
    switch (randomNum) {
        case 0:// text
            message.strContent = [self randomString];
            break;
        case 1:// picture
            message.picture = [UIImage imageNamed:@"haha.jpeg"];
            break;
            //            case 2:// audio
            //                [dictionary setObject:@"" forKey:@"voice"];
            //                [dictionary setObject:@"" forKey:@"strVoiceTime"];
            //                break;
        default:
            break;
    }
    NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
    message.from = IRMessageFromOther;
    message.type = randomNum;
    message.strTime = [date description];
    message.strIcon = @"http://3.bp.blogspot.com/-2bS7s_58AN8/U5QqhnoSuYI/AAAAAAAAA1M/Gm7PXvMm7Wk/s1600/IMG-20140529-WA0020.jpg";
    
    return message;
}


- (NSString *)randomString {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales. Vestibulum ut est id mauris ultrices gravida. Nulla malesuada metus ut erat malesuada, vitae ornare neque semper. Aenean a commodo justo, vel placerat odio";
    
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(3, r); // no less than 3 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    return [NSString stringWithFormat:@"%@!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
}

@end