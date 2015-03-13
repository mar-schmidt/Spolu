//
//  IRChatDataSourceManager.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-27.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRChatDataSourceManager.h"

@implementation IRChatDataSourceManager

- (id)init
{
    self = [super init];
    if (self) {
        // Register for new messages notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessageNotification:) name:@"newMessageReceived" object:nil];
        
        _conversationsDataSource = [[NSMutableArray alloc] init];
        _ownGroup = [IROwnGroup sharedGroup];
    }
    return self;
}

+ (IRChatDataSourceManager *)sharedChatDataSourceManager {
    static IRChatDataSourceManager *sharedChatDataSourceManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedChatDataSourceManager = [[self alloc] init];
    });
    
    return sharedChatDataSourceManager;
}

/****
*
* Self -> WebSocketServiceHandler
* We need to send through our received message to the WebSocketServiceHandler
*
****/
- (void)sendMessageToWebSocketServiceHandler:(IRMessage *)message toGroup:(IRGroup *)group
{
    IRWebSocketServiceHandler *webSocketServiceHandler = [IRWebSocketServiceHandler sharedWebSocketHandler];
    
    [webSocketServiceHandler sendMessage:message toGroup:group withCompletionBlockSuccess:^(BOOL succeeded) {
        if (succeeded) {
            NSLog(@"Successfully sent to backend");
        }
    } failure:^(NSError *error) {
        NSLog(@"Error when sending to backend: %@", error.localizedDescription);
    }];
}


- (void)sendMessage:(IRMessage *)message forGroupConversation:(IRGroupConversation *)groupConversation
{
    // Begin encapsulating message in messageframe, then update the conversationDataSource array as well as sending message through to websocketservicehandler
    [_currentConversationDataSource.messages addObject:[self embedMessageInMessageFrame:message]];
    [self sendMessageToWebSocketServiceHandler:message toGroup:groupConversation.group];
}



/****
*
* This is called once every 18000 seconds (5 hours) to remove the group conversation due to we only want to keep conversations for 5 hours
*
****/
- (void)removeGroupConversationFromDataSource:(IRGroupConversation *)groupConversation
{
    
}

- (void)removeExpiredGroupConversationsFromDataSource
{
    for (IRGroupConversation *chat in _conversationsDataSource) {
        NSTimeInterval interval = [chat.startedAt timeIntervalSinceDate:[NSDate date]];
        if (interval >= 18000) { // 5hours
            [_conversationsDataSource removeObject:chat];
        }
    }
}

- (NSMutableArray *)sortArrayByDate:(NSMutableArray *)array
{
    NSSortDescriptor *valueDescriptorGroup = [[NSSortDescriptor alloc] initWithKey:@"latestReceivedMessage" ascending:NO];
    
    NSArray *descriptors = @[valueDescriptorGroup];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:descriptors];
    
    return [sortedArray mutableCopy];
}

#pragma mark IRWebSocketServiceHanderDelegate
- (void)didReceiveNewMessageNotification:(NSNotification *)notification
{
    /*****
    * This will check if any existing group chats for received group exist in the dataSource.
    *
    * If YES, previous conversation exists with this group
    * Add the message to the currentGroupChat messages array and proceed in notifying the InteractionsChatModel about the new message
    *
    * If NO, no previous conversation exists in our dataSource, probably its the first message in an new conversation.
    * Init a new groupChat object, add received group to its group property, add the time the conversation started, add the received message to the its messages array
    * and finish off by adding the message to the datasource
    *****/
    
    IRMessage *receivedMessage = notification.userInfo[@"message"];
    IRGroup *fromGroup = notification.userInfo[@"group"];
    
    if (_conversationsDataSource.count > 0) {
        // If message comes from existing group, add it to its messages array. Otherwise we'll add a new conversation
        for (IRGroupConversation *existingGroupConversation in _conversationsDataSource) {
            if ((existingGroupConversation.group.groupId == fromGroup.groupId)) {
                [existingGroupConversation.messages addObject:[self embedMessageInMessageFrame:receivedMessage]];
                existingGroupConversation.latestReceivedMessage = [NSDate date];
                
                // Notifying delegate responder which is InteractionsViewController
                if ([self.delegate respondsToSelector:@selector(chatDataSourceManager:didReceiveMessages:inGroupChat:)]) {
                    [self.delegate chatDataSourceManager:self didReceiveMessages:@[receivedMessage] inGroupChat:existingGroupConversation];
                }
                return;
            }
        }
        // Otherwise, add new conversation
        IRGroupConversation *newGroupConversation = [self createNewGroupConversationWithMessage:receivedMessage fromGroup:fromGroup];
        [_conversationsDataSource addObject:newGroupConversation];
        
        // Notifying delegate responder which is InteractionsChatModel
        if ([self.delegate respondsToSelector:@selector(chatDataSourceManager:didReceiveMessages:inGroupChat:)]) {
            [self.delegate chatDataSourceManager:self didReceiveMessages:newGroupConversation.messages inGroupChat:newGroupConversation];
        }
    } else {
        // Its the first conversation. Create a new one.
        IRGroupConversation *newGroupConversation = [self createNewGroupConversationWithMessage:receivedMessage fromGroup:fromGroup];
        [_conversationsDataSource addObject:newGroupConversation];
        
        // Notifying delegate responder which is InteractionsChatModel
        if ([self.delegate respondsToSelector:@selector(chatDataSourceManager:didReceiveMessages:inGroupChat:)]) {
            [self.delegate chatDataSourceManager:self didReceiveMessages:newGroupConversation.messages inGroupChat:newGroupConversation];
        }

    }
}


- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didFailWithError:(NSError *)error whileSendingToGroup:(IRGroup *)group
{
    
}

static NSString *previousTime = nil;

- (IRGroupConversation *)createNewGroupConversationWithMessage:(IRMessage *)message fromGroup:(IRGroup *)group
{
    IRGroupConversation *newGroupConversation = [[IRGroupConversation alloc] init];
    newGroupConversation.group = group;
    newGroupConversation.startedAt = [NSDate date];
    newGroupConversation.latestReceivedMessage = [NSDate date];
    
    // Instead of adding the IRMessage to the messages array we add the IRMessageFrame object
    IRMessageFrame *messageFrame = [self embedMessageInMessageFrame:message];

    [newGroupConversation.messages addObject:messageFrame];
    
    return newGroupConversation;
}

- (IRMessageFrame *)embedMessageInMessageFrame:(IRMessage *)message
{
    IRMessageFrame *messageFrame = [[IRMessageFrame alloc] init];
    messageFrame.message = message;
    [message minuteOffSetStart:previousTime end:[self currentTime]];
    messageFrame.showTime = message.showDateLabel;
    message.strTime = [self currentTime];
    
    if (message.showDateLabel) {
        previousTime = [[NSDate date] description];
    }
    
    return messageFrame;
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

@end
