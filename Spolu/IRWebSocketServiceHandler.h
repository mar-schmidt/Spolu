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

@protocol WebSocketServiceHandlerDelegate;

@interface IRWebSocketServiceHandler : NSObject
{
    
}

@property (nonatomic, strong) id<WebSocketServiceHandlerDelegate>delegate;


+ (IRWebSocketServiceHandler *)sharedWebSocketHandler;


@end

@protocol WebSocketServiceHandlerDelegate <NSObject>
@optional

// Retrieving
- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didReceiveNewMessage:(IRMessage *)message fromGroup:(IRGroup *)group;

// Send
- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didSendMessage:(IRMessage *)message;

// Error
- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didFailWithError:(NSError *)error;
@end