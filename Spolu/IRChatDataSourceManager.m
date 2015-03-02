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
        _conversationsDataSource = [[NSMutableArray alloc] init];
        ownGroup = [IROwnGroup sharedGroup];
        _webSocketHandler = [IRWebSocketServiceHandler sharedWebSocketHandler];
        _webSocketHandler.delegate = self;
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
    for (IRGroupConversation *conversation in _conversationsDataSource) {
        if (conversation == groupConversation) {
            [conversation.messages addObject:[self embedMessageInMessageFrame:message]];
        }
    }
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


#pragma mark IRWebSocketServiceHanderDelegate
- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didReceiveNewMessage:(IRMessage *)message fromGroup:(IRGroup *)group
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
    
    if (_conversationsDataSource.count > 0) {
        // If message comes from existing group, add it to its messages array. Otherwise we'll add a new conversation
        for (IRGroupConversation *existingGroupConversation in _conversationsDataSource) {
            if ((existingGroupConversation.group.groupId == group.groupId)) {
                [existingGroupConversation.messages addObject:[self embedMessageInMessageFrame:message]];
                
                // Notifying delegate responder which is InteractionsChatModel
                if ([self.delegate respondsToSelector:@selector(chatDataSourceManager:didReceiveMessages:inGroupChat:)]) {
                    [self.delegate chatDataSourceManager:self didReceiveMessages:@[message] inGroupChat:existingGroupConversation];
                }
                return;
            }
        }
        // Otherwise, add new conversation
        IRGroupConversation *newGroupConversation = [self createNewGroupConversationWithMessage:message fromGroup:group];
        [_conversationsDataSource addObject:newGroupConversation];
        
        // Notifying delegate responder which is InteractionsChatModel
        if ([self.delegate respondsToSelector:@selector(chatDataSourceManager:didReceiveMessages:inGroupChat:)]) {
            [self.delegate chatDataSourceManager:self didReceiveMessages:newGroupConversation.messages inGroupChat:newGroupConversation];
        }
    } else {
        IRGroupConversation *newGroupConversation = [self createNewGroupConversationWithMessage:message fromGroup:group];
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

- (IRGroupConversation *)createNewGroupConversationWithMessage:(IRMessage *)message fromGroup:(IRGroup *)group
{
    IRGroupConversation *newGroupConversation = [[IRGroupConversation alloc] init];
    newGroupConversation.group = group;
    newGroupConversation.startedAt = [NSDate date];
    
    // Instead of adding the IRMessage to the messages array we add the IRMessageFrame object
    IRMessageFrame *messageFrame = [self embedMessageInMessageFrame:message];

    [newGroupConversation.messages addObject:messageFrame];
    
    return newGroupConversation;
}

- (IRMessageFrame *)embedMessageInMessageFrame:(IRMessage *)message
{
    IRMessageFrame *messageFrame = [[IRMessageFrame alloc] init];
    messageFrame.message = message;
    messageFrame.showTime = message.showDateLabel;
    
    return messageFrame;
}

@end
