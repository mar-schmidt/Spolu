//
//  InteractionsConversationsMenuCell.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-10.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRGroupConversation.h"

@interface InteractionsConversationsMenuCell : UITableViewCell

@property (nonatomic, strong) IRGroupConversation *groupConversation;
@property (nonatomic, strong) UIView *circleView;
@property (nonatomic, strong) UIImageView *groupImageView;

@end
