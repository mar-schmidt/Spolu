//
//  IRImageViewDisplayer.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "IRImageViewDisplayer.h"

static UIImageView *orginImageView;

@implementation IRImageViewDisplayer

+ (void)showImage:(UIImageView *)avatarImageView {
    UIImage *image = avatarImageView.image;
    
    orginImageView = avatarImageView;
    orginImageView.alpha = 0;
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    // Blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    backgroundView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    backgroundView.alpha = 0;
    
    // Vibrancy effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    
    // Add the vibrancy view to the blur view
    [[backgroundView contentView] addSubview:vibrancyEffectView];
    
    CGRect oldframe = [avatarImageView convertRect:avatarImageView.bounds toView:window];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:oldframe];
    imageView.image = image;
    imageView.tag = 1;
    
    [window addSubview:backgroundView];
    [backgroundView addSubview:imageView];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideImage:)];
    [backgroundView addGestureRecognizer:tap];
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.frame=CGRectMake(0,
                                   ([UIScreen mainScreen].bounds.size.height - image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width) / 2,
                                   [UIScreen mainScreen].bounds.size.width,
                                   image.size.height * [UIScreen mainScreen].bounds.size.width / image.size.width);
        backgroundView.alpha=1;
    } completion:^(BOOL finished) {
        
    }];
}

+ (void)hideImage:(UITapGestureRecognizer *)tap {
    UIView *backgroundView = tap.view;
    UIImageView *imageView = (UIImageView *)[tap.view viewWithTag:1];
    
    [UIView animateWithDuration:0.2 animations:^{
        imageView.frame = [orginImageView convertRect:orginImageView.bounds toView:[UIApplication sharedApplication].keyWindow];
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        orginImageView.alpha = 1;
    }];
}
@end
