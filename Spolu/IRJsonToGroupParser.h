//
//  IRJsonToGroupParser.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-07.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRGroup.h"

@interface IRJsonToGroupParser : NSObject

+ (IRJsonToGroupParser *)sharedIRJsonToGroupParser;

- (NSMutableArray *)parseGroupsFromResponseObject:(id)responseObject;

@end
