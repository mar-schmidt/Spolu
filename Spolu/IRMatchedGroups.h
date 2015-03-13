//
//  IRMatchedGroups.h
//  
//
//  Created by Marcus Ronélius on 2015-02-24.
//
//

#import "IRGroup.h"
#import "IRMessage.h"
#import "IRGroup.h"
#import "IRGroupConversation.h"

@interface IRMatchedGroups : IRGroup
{
    
}

@property (nonatomic, retain) NSMutableArray *groups;
@property (nonatomic, retain) NSMutableArray *groupConversations;

+ (id)sharedMatchedGroups;

@end
