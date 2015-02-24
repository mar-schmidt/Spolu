//
//  IRProgressHUD.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRProgressHUD.h"

@interface IRProgressHUD ()
{
    NSTimer *myTimer;
    int angle;
    
    UILabel *centerLabel;
    UIImageView *edgeImageView;
    
}
@property (nonatomic, strong, readonly) UIWindow *overlayWindow;


@end

@implementation IRProgressHUD

@synthesize overlayWindow;

+ (IRProgressHUD*)sharedView {
    static dispatch_once_t once;
    static IRProgressHUD *sharedView;
    dispatch_once(&once, ^ {
        sharedView = [[IRProgressHUD alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        //sharedView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.8];
        // Blur effect
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        blurView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        // Vibrancy effect
        UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
        UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
        vibrancyEffectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        // Add the vibrancy view to the blur view
        [[blurView contentView] addSubview:vibrancyEffectView];

        [sharedView addSubview:blurView];
    });
    return sharedView;
}


+ (void)show {
    [[IRProgressHUD sharedView] show];
}

- (void)show {
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!self.superview)
            [self.overlayWindow addSubview:self];
        
        if (!centerLabel){
            centerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 40)];
            centerLabel.backgroundColor = [UIColor clearColor];
        }
        
        if (!self.subTitleLabel){
            self.subTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.subTitleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!self.titleLabel){
            self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 20)];
            self.titleLabel.backgroundColor = [UIColor clearColor];
        }
        if (!edgeImageView)
            edgeImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Chat_record_circle"]];
        
        self.subTitleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 + 30);
        self.subTitleLabel.text = @"Slide up to cancel";
        self.subTitleLabel.textAlignment = NSTextAlignmentCenter;
        self.subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.subTitleLabel.textColor = [UIColor lightGrayColor];
        
        self.titleLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2 - 30);
        self.titleLabel.text = @"Time Left";
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.textColor = [UIColor whiteColor];
        
        centerLabel.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2,[[UIScreen mainScreen] bounds].size.height/2);
        centerLabel.text = @"60";
        centerLabel.textAlignment = NSTextAlignmentCenter;
        centerLabel.font = [UIFont systemFontOfSize:30];
        centerLabel.textColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
        
        
        edgeImageView.frame = CGRectMake(0, 0, 154, 154);
        edgeImageView.center = centerLabel.center;
        [self addSubview:edgeImageView];
        [self addSubview:centerLabel];
        [self addSubview:self.subTitleLabel];
        [self addSubview:self.titleLabel];
        
        if (myTimer)
            [myTimer invalidate];
        myTimer = nil;
        myTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(startAnimation)
                                                 userInfo:nil
                                                  repeats:YES];
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                         }
                         completion:^(BOOL finished){
                         }];
        [self setNeedsDisplay];
    });
}
- (void)startAnimation
{
    angle -= 3;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.09];
    UIView.AnimationRepeatAutoreverses = YES;
    edgeImageView.transform = CGAffineTransformMakeRotation(angle * (M_PI / 180.0f));
    float second = [centerLabel.text floatValue];
    if (second <= 10.0f) {
        centerLabel.textColor = [UIColor redColor];
    }
    
    centerLabel.text = [NSString stringWithFormat:@"%.1f",second-0.1];
    [UIView commitAnimations];
}

+ (void)changeSubTitle:(NSString *)str withFontColor:(UIColor *)color
{
    [[IRProgressHUD sharedView] setState:str withFontColor:color];
}

- (void)setState:(NSString *)str withFontColor:(UIColor *)color
{
    self.subTitleLabel.textColor = color;
    self.subTitleLabel.text = str;
}

+ (void)dismissWithSuccess:(NSString *)str {
    [[IRProgressHUD sharedView] dismiss:str];
}

+ (void)dismissWithError:(NSString *)str {
    [[IRProgressHUD sharedView] dismiss:str];
}

- (void)dismiss:(NSString *)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [myTimer invalidate];
        myTimer = nil;
        self.subTitleLabel.text = nil;
        self.titleLabel.text = nil;
        centerLabel.text = state;
        centerLabel.textColor = [UIColor whiteColor];
        
        CGFloat timeLonger;
        if ([state isEqualToString:@"TooShort"]) {
            timeLonger = 1;
        }else{
            timeLonger = 0.6;
        }
        [UIView animateWithDuration:timeLonger
                              delay:0
                            options:UIViewAnimationCurveEaseIn | UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.alpha = 0;
                             [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                         }
                         completion:^(BOOL finished){
                             if(self.alpha == 0) {
                                 [centerLabel removeFromSuperview];
                                 centerLabel = nil;
                                 [edgeImageView removeFromSuperview];
                                 edgeImageView = nil;
                                 [self.subTitleLabel removeFromSuperview];
                                 self.subTitleLabel = nil;
                                 
                                 NSMutableArray *windows = [[NSMutableArray alloc] initWithArray:[UIApplication sharedApplication].windows];
                                 [windows removeObject:overlayWindow];
                                 overlayWindow = nil;
                                 
                                 [windows enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(UIWindow *window, NSUInteger idx, BOOL *stop) {
                                     if([window isKindOfClass:[UIWindow class]] && window.windowLevel == UIWindowLevelNormal) {
                                         [window makeKeyWindow];
                                         *stop = YES;
                                     }
                                 }];
                             }
                         }];
    });
}

- (UIWindow *)overlayWindow {
    if(!overlayWindow) {
        overlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        overlayWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayWindow.userInteractionEnabled = NO;
        [overlayWindow makeKeyAndVisible];
    }
    return overlayWindow;
}


@end