//
//  IRChatDataSourceManager.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-27.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRWebSocketServiceHandler.h"
#import "IRGroupConversation.h"
#import "IRMessage.h"
#import "IRMessageFrame.h"
#import "IROwnGroup.h"

@protocol ChatDataSourceManagerDelegate;

@interface IRChatDataSourceManager : NSObject <WebSocketServiceHandlerDelegate>
{
    
}

@property (nonatomic, strong) NSMutableArray *conversationsDataSource;
@property (nonatomic, strong) IRGroupConversation *currentConversationDataSource;
@property (nonatomic, strong) IROwnGroup *ownGroup;

@property (nonatomic, strong) IRWebSocketServiceHandler *webSocketHandler;
@property (nonatomic, strong) id<ChatDataSourceManagerDelegate>delegate;

+ (IRChatDataSourceManager *)sharedChatDataSourceManager;
- (void)sendMessage:(IRMessage *)message forGroupConversation:(IRGroupConversation *)groupConversation;

@end

@protocol ChatDataSourceManagerDelegate <NSObject>
@optional

- (void)chatDataSourceManager:(IRChatDataSourceManager *)manager didReceiveMessages:(NSArray *)messages inGroupChat:(IRGroupConversation *)groupChat;
- (void)chatDataSourceManager:(IRChatDataSourceManager *)manager didSendMessage:(IRMessage *)message forGroupChat:(IRGroupConversation *)groupChat;
- (void)chatDataSourceManager:(IRChatDataSourceManager *)manager didFailWithError:(NSError *)error;

@end


