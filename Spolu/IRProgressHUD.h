//
//  IRProgressHUD.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-23.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IRProgressHUD : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subTitleLabel;

+ (void)show;

+ (void)dismissWithSuccess:(NSString *)str;

+ (void)dismissWithError:(NSString *)str;

+ (void)changeSubTitle:(NSString *)str withFontColor:(UIColor *)color;

@end
