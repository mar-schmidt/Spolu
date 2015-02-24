//
//  IRInputFunctionView.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACMacros.h"

@class IRInputFunctionView;

@protocol IRInputFunctionViewDelegate <NSObject>

// Delegate methods
// Text
- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendMessage:(NSString *)message;

// Image
- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendPicture:(UIImage *)image;

// Audio
- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second;

@end

@interface IRInputFunctionView : UIView <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UIButton *btnSendMessage;
@property (nonatomic, retain) UIButton *btnChangeVoiceState;
@property (nonatomic, retain) UIButton *btnVoiceRecord;
@property (nonatomic, retain) UITextView *TextViewInput;

@property (nonatomic, assign) BOOL isAbleToSendTextMessage;

@property (nonatomic, retain) UIViewController *superVC;

@property (nonatomic, assign) id<IRInputFunctionViewDelegate>delegate;


- (id)initWithSuperVC:(UIViewController *)superVC;

- (void)changeSendBtnWithPhoto:(BOOL)isPhoto;

@end
