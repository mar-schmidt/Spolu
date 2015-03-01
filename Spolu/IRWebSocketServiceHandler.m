//
//  IRWebSocketServiceHandler.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-25.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRWebSocketServiceHandler.h"

@implementation IRWebSocketServiceHandler

+ (IRWebSocketServiceHandler *)sharedWebSocketHandler
{
    static IRWebSocketServiceHandler *_sharedWebSocketServiceHandler = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWebSocketServiceHandler = [[self alloc] init];
    });
    return _sharedWebSocketServiceHandler;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Test
        NSDate *d = [NSDate dateWithTimeIntervalSinceNow:5.0];
        NSTimer *t = [[NSTimer alloc] initWithFireDate:d
                                              interval:15
                                                target:self
                                              selector:@selector(sendRandomMessage)
                                              userInfo:nil repeats:YES];
        
        NSRunLoop *runner = [NSRunLoop currentRunLoop];
        [runner addTimer:t forMode: NSDefaultRunLoopMode];
    }
    return self;
}


/****
*
* Message that was sent from local user to group. Forward this to backend
*
****/
- (void)sendMessage:(IRMessage *)message toGroup:(IRGroup *)group withCompletionBlockSuccess:(void (^)(BOOL))success failure:(void (^)(NSError *))failure
{
    NSLog(@"Message: %@\nGroup: %ld", message.strContent, (long)group.groupId);
    
    success(YES);
}


/****
*
* TEMP METHODS: called when receiving a message from backend
*
****/
- (void)receivedMessageFromWebSocket:(NSData *)data
{
    IRMessage *message = [self randomMessage];
    IRMatchedGroups *matchedGroups = [IRMatchedGroups sharedMatchedGroups];
    IRGroup *group = matchedGroups.groups[1];
    
    if ([self.delegate respondsToSelector:@selector(webSocketServiceHandler:didReceiveNewMessage:fromGroup:)]) {
        [self.delegate webSocketServiceHandler:self didReceiveNewMessage:message fromGroup:group];
    }
}







// Test
- (void)sendRandomMessage
{
    if ([self.delegate respondsToSelector:@selector(webSocketServiceHandler:didReceiveNewMessage:fromGroup:)]) {
        
        IRMessage *message = [self randomMessage];
        IRMatchedGroups *matchedGroups = [IRMatchedGroups sharedMatchedGroups];
        IRGroup *group = matchedGroups.groups[1];
        
        NSLog(@"TEST: Received new message");
        if ([self.delegate respondsToSelector:@selector(webSocketServiceHandler:didReceiveNewMessage:fromGroup:)]) {
            [self.delegate webSocketServiceHandler:self didReceiveNewMessage:message fromGroup:group];
        }
    }
}

static int dateNum = 10;
static NSString *previousTime = nil;

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
    
    [message minuteOffSetStart:previousTime end:[self currentTime]];
    
    if (message.showDateLabel) {
        previousTime = [[NSDate date] description];
    }
    
    return message;
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


- (NSString *)randomString {
    
    NSString *lorumIpsum = @"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non quam ac massa viverra semper. Maecenas mattis justo ac augue volutpat congue. Maecenas laoreet, nulla eu faucibus gravida, felis orci dictum risus, sed sodales sem eros eget risus. Morbi imperdiet sed diam et sodales. Vestibulum ut est id mauris ultrices gravida. Nulla malesuada metus ut erat malesuada, vitae ornare neque semper. Aenean a commodo justo, vel placerat odio";
    
    NSArray *lorumIpsumArray = [lorumIpsum componentsSeparatedByString:@" "];
    
    int r = arc4random() % [lorumIpsumArray count];
    r = MAX(3, r); // no less than 3 words
    NSArray *lorumIpsumRandom = [lorumIpsumArray objectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, r)]];
    
    return [NSString stringWithFormat:@"%@!!", [lorumIpsumRandom componentsJoinedByString:@" "]];
}


@end
