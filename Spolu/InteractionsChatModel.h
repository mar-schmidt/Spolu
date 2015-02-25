//
//  InteractionsChatModel.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRMessage.h"
#import "IROwnGroup.h"
#import "IRMatchedGroups.h"
#import "IRWebSocketServiceHandler.h"

@interface InteractionsChatModel : NSObject
{
    IROwnGroup *ownGroup;
    IRMatchedGroups *matchedGroups;
}

@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)populateRandomDataSource;

- (void)addRandomItemsToDataSource:(NSInteger)number;

- (void)sendMessage:(IRMessage *)message;

- (NSArray *)receivedMessages:(NSArray *)messages fromMatchedGroup:(IRGroup *)group;

@end
