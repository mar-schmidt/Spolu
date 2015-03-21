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
        
        _circleView = [[UIView alloc] initWithFrame:CGRectMake(self.bounds.size.width/2-140, 10, 100, 100)];
        _circleView.backgroundColor = [UIColor clearColor];
        _circleView.layer.borderWidth = 1.5;
        _circleView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        _circleView.layer.cornerRadius = _circleView.bounds.size.height/2;
        _circleView.clipsToBounds = YES;
        
        _groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_circleView addSubview:_groupImageView];
        
        
        
        
        _messageMatchLabel = [[UILabel alloc] initWithFrame:CGRectMake(_circleView.frame.origin.x + 105,
                                                                       20,
                                                                       80,
                                                                       80)];
        _messageMatchLabel.backgroundColor = [UIColor clearColor];
        _messageMatchLabel.numberOfLines = 4;
        _messageMatchLabel.minimumScaleFactor = 0.9f;
        _messageMatchLabel.adjustsFontSizeToFitWidth = YES;
        _messageMatchLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _messageMatchLabel.textAlignment = NSTextAlignmentCenter;
        _messageMatchLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.f];
        
        
        
        
        _latestMessageReceived = [[UILabel alloc] initWithFrame:CGRectMake(_messageMatchLabel.frame.origin.x + _messageMatchLabel.frame.size.width-10,
                                                                           10,
                                                                           50,
                                                                           15)];
        _latestMessageReceived.backgroundColor = [UIColor clearColor];
        _latestMessageReceived.numberOfLines = 1;
        _latestMessageReceived.minimumScaleFactor = 0.4f;
        _latestMessageReceived.adjustsFontSizeToFitWidth = YES;
        _latestMessageReceived.lineBreakMode = NSLineBreakByTruncatingTail;
        _latestMessageReceived.textAlignment = NSTextAlignmentLeft;
        _latestMessageReceived.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.f];
        _latestMessageReceived.textColor = [UIColor darkGrayColor];
        
        
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(8, _circleView.frame.origin.y + _circleView.frame.size.height + 10, self.bounds.size.width - 8, 0.5)];
        bottomLine.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        
        
        [self.contentView addSubview:bottomLine];
        [self.contentView addSubview:_latestMessageReceived];
        [self.contentView addSubview:_messageMatchLabel];
        [self.contentView addSubview:_circleView];
    }
    return self;
}

@end
