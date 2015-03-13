//
//  IRWebSocketServiceHandler.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-25.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRMessage.h"
#import "IRGroup.h"
#import "IRMatchedGroups.h"
#import "IRGroupConversation.h"

@protocol WebSocketServiceHandlerDelegate;

@interface IRWebSocketServiceHandler : NSObject


@property (nonatomic, strong) id<WebSocketServiceHandlerDelegate>delegate;


+ (IRWebSocketServiceHandler *)sharedWebSocketHandler;

- (void)sendMessage:(IRMessage *)message toGroup:(IRGroup *)group withCompletionBlockSuccess:(void (^)(BOOL succeeded))success failure:(void (^)(NSError *error))failure;

@end



/****
*
* Delegates of WebSocketServiceHandler
*
****/
@protocol WebSocketServiceHandlerDelegate <NSObject>
@optional

// Retrieving
- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didReceiveNewMessage:(IRMessage *)message fromGroup:(IRGroup *)group;

// Error
- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didFailWithError:(NSError *)error whileSendingToGroup:(IRGroup *)group;
@end