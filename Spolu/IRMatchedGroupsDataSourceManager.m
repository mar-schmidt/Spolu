//
//  IRMatchedGroupsDataSourceManager.m
//  
//
//  Created by Marcus Ronélius on 2015-02-24.
//
//

#import "IRMatchedGroupsDataSourceManager.h"

@implementation IRMatchedGroupsDataSourceManager

- (id)init
{
    self = [super init];
    if (self) {
        // Register for new messages notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessageNotification:) name:@"newMessageReceived" object:nil];
        // Register for new matches notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMatch:) name:@"newMatchReceived" object:nil];
        
        _groupConversationsDataSource = [[NSMutableArray alloc] init];

    }
    return self;
}

+ (id)sharedMatchedGroups {
    static IRMatchedGroupsDataSourceManager *_sharedIRMatchedGroupsDataSourceManager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedIRMatchedGroupsDataSourceManager = [[self alloc] init];
    });
    
    return _sharedIRMatchedGroupsDataSourceManager;
}


- (void)sendMessage:(IRMessage *)message forGroupConversation:(IRGroupConversation *)groupConversation
{
    // Begin encapsulating message in messageframe, then update the conversationDataSource array as well as sending message through to websocketservicehandler
    [_currentConversationDataSource.messages addObject:[self embedMessageInMessageFrame:message]];
    
    IROwnGroup *ownGroup = [IROwnGroup sharedGroup];
    [self sendMessageToWebSocketServiceHandler:message toGroup:groupConversation.group fromGroup:ownGroup];
}



/****
 *
 * Self -> WebSocketServiceHandler
 * We need to send through our received message to the WebSocketServiceHandler
 *
 ****/
- (void)sendMessageToWebSocketServiceHandler:(IRMessage *)message toGroup:(IRGroup *)group fromGroup:(IROwnGroup *)fromGroup
{
    IRWebSocketServiceHandler *webSocketServiceHandler = [IRWebSocketServiceHandler sharedWebSocketHandler];
    
    [webSocketServiceHandler sendMessage:@{
                                           @"user_id":          [NSString stringWithFormat:@"%ld", (long)fromGroup.group.groupId], // My user
                                           @"other_user_id":    [NSString stringWithFormat:@"%ld", (long)group.groupId], // User we send to
                                           @"text":             message.strContent // Message we send
                                           }
                                 toGroup:group
                               toChannel:group.channel];
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
    for (IRGroupConversation *chat in _groupConversationsDataSource) {
        NSTimeInterval interval = [chat.startedAt timeIntervalSinceDate:[NSDate date]];
        if (interval >= 18000) { // 5hours
            [_groupConversationsDataSource removeObject:chat];
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
    NSString *channel = notification.userInfo[@"channel"];
    
    if (_groupConversationsDataSource.count > 0) {
        // If message comes from existing group, add it to its messages array. Otherwise we'll add a new conversation
        for (IRGroupConversation *existingGroupConversation in _groupConversationsDataSource) {
            if ((existingGroupConversation.group.groupId == fromGroup.groupId)) {
                [existingGroupConversation.messages addObject:[self embedMessageInMessageFrame:receivedMessage]];
                existingGroupConversation.latestReceivedMessage = [NSDate date];
                existingGroupConversation.conversationChannel = channel;
                
                // Notifying delegate responder which is InteractionsViewController
                if ([self.delegate respondsToSelector:@selector(matchedGroupsDataSourceManager:didReceiveMessages:inGroupChat:)]) {
                    [self.delegate matchedGroupsDataSourceManager:self didReceiveMessages:@[receivedMessage] inGroupChat:existingGroupConversation];
                }
                return;
            }
        }
        // Otherwise, add new conversation
        IRGroupConversation *newGroupConversation = [self createNewGroupConversationWithMessage:receivedMessage fromGroup:fromGroup];
        [_groupConversationsDataSource addObject:newGroupConversation];
        
        // Notifying delegate responder which is InteractionsChatModel
        if ([self.delegate respondsToSelector:@selector(matchedGroupsDataSourceManager:didReceiveMessages:inGroupChat:)]) {
            [self.delegate matchedGroupsDataSourceManager:self didReceiveMessages:newGroupConversation.messages inGroupChat:newGroupConversation];
        }
    } else {
        // Its the first conversation. Create a new one.
        IRGroupConversation *newGroupConversation = [self createNewGroupConversationWithMessage:receivedMessage fromGroup:fromGroup];
        newGroupConversation.conversationChannel = channel;
        [_groupConversationsDataSource addObject:newGroupConversation];
        
        // Notifying delegate responder which is InteractionsChatModel
        if ([self.delegate respondsToSelector:@selector(matchedGroupsDataSourceManager:didReceiveMessages:inGroupChat:)]) {
            [self.delegate matchedGroupsDataSourceManager:self didReceiveMessages:newGroupConversation.messages inGroupChat:newGroupConversation];
        }
        
    }
}

- (void)didReceiveNewMatch:(NSNotification *)notification
{
    IRGroupConversation *groupConversation = notification.userInfo[@"group"];
    NSString *channel = notification.userInfo[@"channel"];
    
    // Adding this due to a shitty bug i cannot track. Take _currentGroup.groupId (since its correct) and point it to a new IRGroup instance which we will use for the async like response block. Later we will get ID in the response which we can double check against.
    NSMutableArray *groupIds = [[NSMutableArray alloc] init];
    for (IRGroupConversation *conversation in _groupConversationsDataSource) {
        [groupIds addObject:[NSNumber numberWithInteger:conversation.group.groupId]];
    }
    if (![groupIds containsObject:[NSNumber numberWithInteger:groupConversation.group.groupId]]) {
        groupConversation.conversationChannel = channel;
        [_groupConversationsDataSource addObject:groupConversation];
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
    
    // If we got a message add it. Could be that we do not have a message, if a conversation did not take place yet.
    if (message) {
        // Instead of adding the IRMessage to the messages array we add the IRMessageFrame object
        IRMessageFrame *messageFrame = [self embedMessageInMessageFrame:message];
        
        [newGroupConversation.messages addObject:messageFrame];
    }
    
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
