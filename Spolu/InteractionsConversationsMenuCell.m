//
//  InteractionsConversationsMenuCell.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-03-10.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "InteractionsConversationsMenuCell.h"

@implementation InteractionsConversationsMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Custom initialization
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _circleView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-100, 10, 130, 130)];
        _circleView.backgroundColor = [UIColor clearColor];
        _circleView.layer.borderWidth = 1.5;
        _circleView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        _circleView.layer.cornerRadius = _circleView.bounds.size.height/2;
        _circleView.clipsToBounds = YES;
        
        _groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 130, 130)];
        
        [_circleView addSubview:_groupImageView];
        [self.contentView addSubview:_circleView];
    }
    return self;
}

@end
