//
//  IRWebSocketServiceHandler.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-25.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MZFayeClient.h>
#import "IRMessage.h"
#import "IRGroup.h"
#import "IRMatchedGroupsDataSourceManager.h"
#import "IRGroupConversation.h"

@interface IRWebSocketServiceHandler : NSObject <MZFayeClientDelegate>

@property (nonatomic, strong) MZFayeClient *webSocketClient;
@property (nonatomic) BOOL isConnected;
@property (nonatomic, strong) NSString *clientId;

/**
 * This will initiate a connection with backend faye server, however, it will not connect until connection method is called
 */
+ (IRWebSocketServiceHandler *)sharedWebSocketHandler;

/**
 * Returns whether we are connected to backend faye server
 */
- (BOOL)isConnected;

/**
 * Connected to backend faye server
 */
- (void)connect;

/**
 * Subscribes to a channel
 */
- (void)subscribeToChannel:(NSString *)channel;

/**
 * Subscribes to all available channels (conversations) in IRMatchedGroupsDataSourceManager.groupConversationsDataSource
 */
- (void)subscribeToAllAvailableChannels;

/**
 * Sends a message to a specific group and channel
 */
- (void)sendMessage:(NSDictionary *)message toGroup:(IRGroup *)group toChannel:(NSString *)channel;

/**
 * Finds the current groupConversation object
 */
- (void)getGroupConversationForUser:(NSString *)user withCompletionBlock:(void (^)(IRGroupConversation *blockGroupConversation))groupFromChannel;

/**
 * Creates a new messageObject from input string
 */
- (IRMessage *)createNewMessageFromGroupConversation:(IRGroupConversation *)groupConversation withMessage:(NSString *)receivedMessage;

@end