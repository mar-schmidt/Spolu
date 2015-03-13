//
//  IRMatchedGroupsDataSourceManager.h
//  
//
//  Created by Marcus Ronélius on 2015-02-24.
//
//

#import <Foundation/Foundation.h>
#import "IRWebSocketServiceHandler.h"
#import "IRGroup.h"
#import "IRMessage.h"
#import "IROwnGroup.h"
#import "IRGroupConversation.h"
#import "IRMessage.h"
#import "IRMessageFrame.h"

@protocol MatchedGroupsDataSourceManagerDelegate;

@class IRWebSocketServiceHandler;

@interface IRMatchedGroupsDataSourceManager : IRGroup
{
    
}

@property (nonatomic, retain) NSMutableArray *groupConversationsDataSource;
@property (nonatomic, strong) IRGroupConversation *currentConversationDataSource;
@property (nonatomic, strong) IRGroup *ownGroup;
@property (nonatomic, strong) IRWebSocketServiceHandler *webSocketHandler;
@property (nonatomic, strong) id<MatchedGroupsDataSourceManagerDelegate>delegate;


+ (id)sharedMatchedGroups;
- (void)sendMessage:(IRMessage *)message forGroupConversation:(IRGroupConversation *)groupConversation;
- (IRGroupConversation *)createNewGroupConversationWithMessage:(IRMessage *)message fromGroup:(IRGroup *)group;

@end

@protocol MatchedGroupsDataSourceManagerDelegate <NSObject>
@optional

- (void)matchedGroupsDataSourceManager:(IRMatchedGroupsDataSourceManager *)manager didReceiveMessages:(NSArray *)messages inGroupChat:(IRGroupConversation *)groupChat;
- (void)matchedGroupsDataSourceManager:(IRMatchedGroupsDataSourceManager *)manager didSendMessage:(IRMessage *)message forGroupChat:(IRGroupConversation *)groupChat;
- (void)matchedGroupsDataSourceManager:(IRMatchedGroupsDataSourceManager *)manager didFailWithError:(NSError *)error;

@end
