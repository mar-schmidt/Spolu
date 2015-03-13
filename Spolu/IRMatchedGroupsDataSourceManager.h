//
//  IRMatchedGroupsDataSourceManager.h
//  
//
//  Created by Marcus Ronélius on 2015-02-24.
//
//

#import "IRGroup.h"
#import "IRMessage.h"
#import "IRGroup.h"
#import "IRGroupConversation.h"

@interface IRMatchedGroupsDataSourceManager : IRGroup
{
    
}

@property (nonatomic, retain) NSMutableArray *groups;

+ (id)sharedMatchedGroups;

@end
