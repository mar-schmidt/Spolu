//
//  IRMessageFrame.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRMessageFrame.h"
#import "IRMessage.h"

@implementation IRMessageFrame

- (void)setMessage:(IRMessage *)message{
    
    _message = message;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    
    if (_showTime){
        CGFloat timeY = ChatMargin;
        CGSize timeSize = [_message.strTime sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
        
        CGFloat timeX = (screenW - timeSize.width) / 2;
        _timeF = CGRectMake(timeX, timeY, timeSize.width + ChatTimeMarginW, timeSize.height + ChatTimeMarginH);
    }
    
    CGFloat iconX = ChatMargin;
    if (_message.from == IRMessageFromMe) {
        iconX = screenW - ChatMargin - ChatIconWH;
    }
    CGFloat iconY = CGRectGetMaxY(_timeF) + ChatMargin;
    _iconF = CGRectMake(iconX, iconY, ChatIconWH, ChatIconWH);
    
    _nameF = CGRectMake(iconX, iconY+ChatIconWH, ChatIconWH, 20);
    
    CGFloat contentX = CGRectGetMaxX(_iconF)+ChatMargin;
    CGFloat contentY = iconY;
    
    CGSize contentSize;
    switch (_message.type) {
        case IRMessageTypeText:
            contentSize = [_message.strContent sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(ChatContentW, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            
            break;
        case IRMessageTypePicture:
            contentSize = CGSizeMake(ChatPicWH, ChatPicWH+10);
            break;
        case IRMessageTypeVoice:
            contentSize = CGSizeMake(120, 27);
            break;
        default:
            break;
    }
    if (_message.from == IRMessageFromMe) {
        contentX = iconX - contentSize.width - ChatContentLeft - ChatContentRight - ChatMargin;
    }
    _contentF = CGRectMake(contentX, contentY, contentSize.width + ChatContentLeft + ChatContentRight, contentSize.height + ChatContentTop + ChatContentBottom);
    
    _cellHeight = MAX(CGRectGetMaxY(_contentF), CGRectGetMaxY(_nameF))  + ChatMargin;
    
}

@end
