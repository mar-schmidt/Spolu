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
        _webSocketClient = [[MZFayeClient alloc] initWithURL:[NSURL URLWithString:@"ws://192.168.1.137:3000/faye"]];
        _webSocketClient.delegate = self;
    }
    return self;
}

- (BOOL)isConnected
{
    BOOL connected;
    
    if ([_webSocketClient isConnected]) {
        connected = YES;
    } else {
        connected = NO;
    }
        
    return connected;
}

- (void)connect
{
    [_webSocketClient connect];
}



- (void)subscribeToChannel:(NSString *)channel
{
    NSLog(@"Subscribing to channel: %@", channel);
    [_webSocketClient subscribeToChannel:channel];
}

- (void)subscribeToAllAvailableChannels
{
    IRMatchedGroupsDataSourceManager *matchedGroupDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
    for (IRGroupConversation *groupConversation in matchedGroupDataSourceManager.groupConversationsDataSource) {
        [self subscribeToChannel:groupConversation.conversationChannel];
    }
}

- (void)sendMessage:(NSDictionary *)message toGroup:(IRGroup *)group toChannel:(NSString *)channel
{
    IROwnGroup *ownGroup = [IROwnGroup sharedGroup];
    NSLog(@"Sending message: %@, from my group: %ld to group: %ld, to channel: %@...", [message objectForKey:@"text"], (long)ownGroup.group.groupId, (long)group.groupId, channel);
    
    [_webSocketClient sendMessage:message toChannel:channel];
}




#pragma mark MZFayeClientDelegates
- (void)fayeClient:(MZFayeClient *)client didConnectToURL:(NSURL *)url
{
    NSLog(@"Connected to faye server on %@", url);
    IRMatchedGroupsDataSourceManager *matchedGroupDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
    if (matchedGroupDataSourceManager.groupConversationsDataSource.count > 0) {
        [self subscribeToAllAvailableChannels];
    }
}

- (void)fayeClient:(MZFayeClient *)client didDisconnectWithError:(NSError *)error
{
    NSLog(@"Disconnected to faye server with error: %@", error.localizedDescription);
}

- (void)fayeClient:(MZFayeClient *)client didSubscribeToChannel:(NSString *)channel
{
    NSLog(@"Subscribed to channel: %@", channel);
}

- (void)fayeClient:(MZFayeClient *)client didUnsubscribeFromChannel:(NSString *)channel
{
    NSLog(@"Unsubscribed from channel: %@", channel);
}

- (void)fayeClient:(MZFayeClient *)client didFailWithError:(NSError *)error
{
    NSLog(@"Faye error: %@", error.localizedDescription);
}

- (void)fayeClient:(MZFayeClient *)client didReceiveMessage:(NSDictionary *)messageData fromChannel:(NSString *)channel
{
    IROwnGroup *ownGroup = [IROwnGroup sharedGroup];

    [self getGroupConversationForUser:[messageData objectForKey:@"user_id"] withCompletionBlock:^(IRGroupConversation *groupConversation) {
        if (groupConversation) {
            // Check if this is from my own group. If not, proceed and received the message
            NSString *receivedFromUserId = [messageData objectForKey:@"user_id"];
            NSString *ownUserId = [NSString stringWithFormat:@"%ld", (long)ownGroup.group.groupId];
            
            if (![receivedFromUserId isEqualToString:ownUserId]) {
                NSLog(@"Received message from faye: %@, from channel: %@", messageData[@"text"], channel);
                IRMessage *message = [self createNewMessageFromGroupConversation:groupConversation withMessage:messageData[@"text"]];
                
                NSDictionary *userInfo = @{@"message" : message,
                                           @"group" : groupConversation.group,
                                           @"channel" : channel};
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc postNotificationName:@"newMessageReceived" object:self userInfo:userInfo];

            }
        }
        // Error handling goes here
    }];
}




- (void)getGroupConversationForUser:(NSString *)user withCompletionBlock:(void (^)(IRGroupConversation *blockGroupConversation))groupFromChannel
{
    IRMatchedGroupsDataSourceManager *matchedGroupsDataSource = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
    if (matchedGroupsDataSource.groupConversationsDataSource.count > 0) {
        // If there are a group in matchedGroupDataSource.groupConversationsDataSource which corresponds to the input channel, return it
        for (IRGroupConversation *groupConversation in matchedGroupsDataSource.groupConversationsDataSource) {
            NSString *groupId = [NSString stringWithFormat:@"%ld", (long)groupConversation.group.groupId];
            if ([groupId isEqualToString:user]) {
                groupFromChannel(groupConversation);
                return;
            }
        }

    } else {
        // We doesnt seems to have any matchedGroups.. This wouldnt happen if we do have a received message, but could occur if user has shut down the app completely. Therefor, get the current matches first
        NSLog(@"No local groupsConversations that corresponds to the received message-channel was found. Looking in backend...");
        IRMatchServiceHandler *matchedServiceHandler = [IRMatchServiceHandler sharedMatchServiceHandler];
    
        [matchedServiceHandler getMatchesConversationsWithCompletionBlock:^(NSArray *groupConversations) {
            for (IRGroupConversation *groupConversation in groupConversations) {
                if ([groupConversation.conversationChannel isEqualToString:user]) {
                    // Return the new group to the block
                    NSLog(@"Found corresponding group conversations in backend");
                    groupFromChannel(groupConversation);
                    return;
                }
            }

        } failure:^(NSError *error) {
            NSLog(@"Failed receiving group conversations from backend. Exiting...");
        }];
    }
    
    if (!groupFromChannel) {
        // No local groupConversation or backendGroupConversation was found, exiting...
        NSLog(@"Received message from unknown (local and backend) group conversation... Ignoring message");
    }
}

static int dateNum = 10;
static NSString *previousTime = nil;

- (IRMessage *)createNewMessageFromGroupConversation:(IRGroupConversation *)groupConversation withMessage:(NSString *)receivedMessage
{
    IRMessage *message = [[IRMessage alloc] init];
    /*
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
     */
    NSDate *date = [[NSDate date]dateByAddingTimeInterval:arc4random()%1000*(dateNum++) ];
    message.from = IRMessageFromOther;
    message.type = 0; // Todo, change depending on image, voice or text. Going for text atm
    message.strTime = [date description];
    message.strIcon = groupConversation.group.imageUrl;
    message.readFlag = NO;
    message.fromGroup = groupConversation.group;
    message.strContent = receivedMessage;
    
    [message minuteOffSetStart:previousTime end:[self currentTime]];
    
    if (message.showDateLabel) {
        previousTime = [[NSDate date] description];
    }
    
    return message;
    
}



























// Test
- (void)sendRandomMessage
{

    /*
    if ([self.delegate respondsToSelector:@selector(webSocketServiceHandler:didReceiveNewMessage:fromGroup:)]) {
        [self.delegate webSocketServiceHandler:self didReceiveNewMessage:message fromGroup:group];
    }
     */

}


- (IRMessage *)randomMessageFromGroup:(IRGroup *)group
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
    message.strIcon = group.imageUrl;
    message.readFlag = NO;
    
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
