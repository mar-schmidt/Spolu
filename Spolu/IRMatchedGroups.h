//
//  IRMatchedGroups.h
//  
//
//  Created by Marcus Ronélius on 2015-02-24.
//
//

#import "IRGroup.h"

@interface IRMatchedGroups : IRGroup
{
    
}

@property (nonatomic, retain) NSMutableArray *groups;

+ (id)sharedMatchedGroups;

@end
