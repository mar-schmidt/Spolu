//
//  IRMessageCell.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "IRMessageContentButton.h"

@class IRMessageFrame;
@class IRMessageCell;

@protocol IRMessageCellDelegate <NSObject>
@optional
- (void)headImageDidClick:(IRMessageCell *)cell image:(UIImage *)image;
- (void)cellContentDidClick:(IRMessageCell *)cell image:(UIImage *)contentImage;
@end


@interface IRMessageCell : UITableViewCell

@property (nonatomic, retain) UILabel *labelTime;
@property (nonatomic, retain) UILabel *labelNum;
@property (nonatomic, retain) UIButton *btnHeadImage;

@property (nonatomic, retain) IRMessageContentButton *btnContent;

@property (nonatomic, retain) IRMessageFrame *messageFrame;

@property (nonatomic, assign) id<IRMessageCellDelegate>delegate;

@end