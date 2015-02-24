//
//  IRMessageCell.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "ACMacros.h"
#import "IRMessageCell.h"
#import "IRMessage.h"
#import "IRMessageFrame.h"
#import "IRAVAudioPlayer.h"
#import "UIImageView+AFNetworking.h"
#import "UIButton+AFNetworking.h"
#import "IRImageViewDisplayer.h"

@interface IRMessageCell () <IRAVAudioPlayerDelegate>
{
    AVAudioPlayer *player;
    NSString *voiceURL;
    NSData *songData;
    
    IRAVAudioPlayer *audio;
    
    UIView *headImageBackView;
}
@end

@implementation IRMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.labelTime = [[UILabel alloc] init];
        self.labelTime.textAlignment = NSTextAlignmentCenter;
        self.labelTime.textColor = [UIColor grayColor];
        self.labelTime.font = ChatTimeFont;
        [self.contentView addSubview:self.labelTime];
        
        headImageBackView = [[UIView alloc]init];
        headImageBackView.layer.cornerRadius = 22;
        headImageBackView.layer.masksToBounds = YES;
        headImageBackView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.4];
        [self.contentView addSubview:headImageBackView];
        self.btnHeadImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnHeadImage.layer.cornerRadius = 20;
        self.btnHeadImage.layer.masksToBounds = YES;
        [self.btnHeadImage addTarget:self action:@selector(btnHeadImageClick:)  forControlEvents:UIControlEventTouchUpInside];
        [headImageBackView addSubview:self.btnHeadImage];
        
        self.labelNum = [[UILabel alloc] init];
        self.labelNum.textColor = [UIColor grayColor];
        self.labelNum.textAlignment = NSTextAlignmentCenter;
        self.labelNum.font = ChatTimeFont;
        [self.contentView addSubview:self.labelNum];
        
        self.btnContent = [IRMessageContentButton buttonWithType:UIButtonTypeCustom];
        [self.btnContent setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.btnContent.titleLabel.font = ChatContentFont;
        self.btnContent.titleLabel.numberOfLines = 0;
        [self.btnContent addTarget:self action:@selector(btnContentClick)  forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.btnContent];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(IRAVAudioPlayerDidFinishPlay) name:@"VoicePlayHasInterrupt" object:nil];
        
    }
    return self;
}

- (void)btnHeadImageClick:(UIButton *)button{
    if ([self.delegate respondsToSelector:@selector(headImageDidClick:userId:)])  {
        [self.delegate headImageDidClick:self userId:self.messageFrame.message.strId];
    }
}


- (void)btnContentClick{
    // Play audio
    if (self.messageFrame.message.type == IRMessageTypeVoice) {
        
        audio = [IRAVAudioPlayer sharedInstance];
        audio.delegate = self;
        //        [audio playSongWithUrl:voiceURL];
        [audio playSongWithData:songData];
    }
    // Show the picture
    else if (self.messageFrame.message.type == IRMessageTypePicture)
    {
        if (self.btnContent.backImageView) {
            [IRImageViewDisplayer showImage:self.btnContent.backImageView];
        }
        if ([self.delegate isKindOfClass:[UIViewController class]]) {
            [[(UIViewController *)self.delegate view] endEditing:YES];
        }
    }
    // Show text to copy it
    else if (self.messageFrame.message.type == IRMessageTypeText)
    {
        [self.btnContent becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:self.btnContent.frame inView:self.btnContent.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)IRAVAudioPlayerBeginLoadVoice
{
    [self.btnContent benginLoadVoice];
}
- (void)IRAVAudioPlayerBeiginPlay
{
    [self.btnContent didLoadVoice];
}
- (void)IRAVAudioPlayerDidFinishPlay
{
    [self.btnContent stopPlay];
    [[IRAVAudioPlayer sharedInstance] stopSound];
}


- (void)setMessageFrame:(IRMessageFrame *)messageFrame{
    
    _messageFrame = messageFrame;
    IRMessage *message = messageFrame.message;
    
    self.labelTime.text = message.strTime;
    self.labelTime.frame = messageFrame.timeF;
    
    headImageBackView.frame = messageFrame.iconF;
    self.btnHeadImage.frame = CGRectMake(2, 2, ChatIconWH-4, ChatIconWH-4);
    if (message.from == IRMessageFromMe) {
        [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:message.strIcon]];
    }else{
        [self.btnHeadImage setBackgroundImageForState:UIControlStateNormal withURL:[NSURL URLWithString:message.strIcon]];
    }
    
    self.labelNum.text = message.strName;
    if (messageFrame.nameF.origin.x > 160) {
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x - 50, messageFrame.nameF.origin.y + 3, 100, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentRight;
    }else{
        self.labelNum.frame = CGRectMake(messageFrame.nameF.origin.x, messageFrame.nameF.origin.y + 3, 80, messageFrame.nameF.size.height);
        self.labelNum.textAlignment = NSTextAlignmentLeft;
    }
    
    //prepare for reuse
    [self.btnContent setTitle:@"" forState:UIControlStateNormal];
    self.btnContent.voiceBackView.hidden = YES;
    self.btnContent.backImageView.hidden = YES;
    
    self.btnContent.frame = messageFrame.contentF;
    
    if (message.from == IRMessageFromMe) {
        self.btnContent.isMyMessage = YES;
        [self.btnContent setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentRight, ChatContentBottom, ChatContentLeft);
    }else{
        self.btnContent.isMyMessage = NO;
        [self.btnContent setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.btnContent.contentEdgeInsets = UIEdgeInsetsMake(ChatContentTop, ChatContentLeft, ChatContentBottom, ChatContentRight);
    }
    
    switch (message.type) {
        case IRMessageTypeText:
            [self.btnContent setTitle:message.strContent forState:UIControlStateNormal];
            break;
        case IRMessageTypePicture:
        {
            self.btnContent.backImageView.hidden = NO;
            self.btnContent.backImageView.image = message.picture;
        }
            break;
        case IRMessageTypeVoice:
        {
            self.btnContent.voiceBackView.hidden = NO;
            self.btnContent.second.text = [NSString stringWithFormat:@"%@ seconds",message.strVoiceTime];
            songData = message.voice;
            // VoiceURL = [NSString stringWithFormat:@"%@%@",RESOURCE_URL_HOST,message.strVoice];
        }
            break;
            
        default:
            break;
    }
    
    UIImage *normal;
    if (message.from == IRMessageFromMe) {
        normal = [UIImage imageNamed:@"chatto_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 22)];
    }
    else{
        normal = [UIImage imageNamed:@"chatfrom_bg_normal"];
        normal = [normal resizableImageWithCapInsets:UIEdgeInsetsMake(35, 22, 10, 10)];
    }
    
    [self.btnContent setBackgroundImage:normal forState:UIControlStateNormal];
    [self.btnContent setBackgroundImage:normal forState:UIControlStateHighlighted];
}

@end
