//
//  InteractionsChatModel.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InteractionsChatModel : NSObject

@property (nonatomic, strong) NSMutableArray *dataSource;

- (void)populateRandomDataSource;

- (void)addRandomItemsToDataSource:(NSInteger)number;

- (void)addSpecifiedItem:(NSDictionary *)dic;

@end
