//
//  ResultGroupMenu.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#define GENERIC_IMAGE_FRAME CGRectMake(0, 0, 40, 40)
#define MENU_WIDTH 200

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "ResultGroupMenu.h"
#import "UIView+Animation.h"
//#import "InteractionsConversationsMenuCell.h"


@implementation ResultGroupMenu

- (instancetype)initFromViewController:(id)sender
{
    if ((self = [super init])) {
        [[NSBundle mainBundle] loadNibNamed:@"ResultGroupMenu" owner:self options:nil];
        
        [self commonInit:sender];
        

        //[menuTable reloadData];
    }
    return self;
}

- (void)toggleMenu {
    if(!isOpen){
        [self show];
    } else {
        [self hide];
    }
}

- (void)show {
    if(!isOpen){
        [self.parent showStatusBar:NO];
        [UIView animateWithDuration:0.2 animations:^{
            
            self.frame = CGRectMake(xAxis, yAxis, width, height);
            menuTable.frame = CGRectMake(menuTable.frame.origin.x, menuTable.frame.origin.y+15, width, height);
            menuTable.alpha = 1;
            //backGroundImage.frame = CGRectMake(0, 0, width, height);
            backGroundImage.alpha = 1;
        } completion:^(BOOL finished) {
            
        }];
        isOpen = YES;
    }
}

- (void)hide {
    if(isOpen) {
        [self.parent showStatusBar:YES];
        [UIView animateWithDuration:0.2 animations:^{
            self.frame = CGRectMake(-width, yAxis, width, height);
            menuTable.frame = CGRectMake(-menuTable.frame.origin.x, menuTable.frame.origin.y-15, width, height);
            //menuTable.alpha = 0;
            //backGroundImage.alpha = 0;
            //backGroundImage.frame = CGRectMake(width, 0, width, height);
        }];
        isOpen = NO;
    }
}

#pragma -mark Private helpers
- (void)commonInit:(UIViewController *)sender {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    xAxis = 0;
    yAxis = 0;
    height = screenSize.size.height;
    width = MENU_WIDTH;
    
    self.frame = CGRectMake(-width, yAxis, width, height);
    
    // This is needed for the blurry background on menuTable
    self.backgroundColor = [UIColor clearColor];
    
    //menuTable = [[UITableView alloc]initWithFrame:CGRectMake(xAxis, yAxis, width, height) style:UITableViewStyleGrouped];
 
    // Blur effect
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *backgroundView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    backgroundView.frame = CGRectMake(0, 0, MENU_WIDTH, height);
    
    // Vibrancy effect
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    vibrancyEffectView.frame = CGRectMake(0, 0, MENU_WIDTH, height);
    
    // Add the vibrancy view to the blur view
    [self addSubview:backgroundView];

    //[menuTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    //[menuTable setShowsVerticalScrollIndicator:NO];
    
    //menuTable.backgroundColor = [UIColor clearColor];
    //menuTable.delegate = self;
    //menuTable.dataSource = self;
    
    [self addSubview:_view];
    
    _ownGroupImageView.layer.borderWidth = 1;
    _ownGroupImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _ownGroupImageView.layer.cornerRadius = _ownGroupImageView.bounds.size.height/2;
    _ownGroupImageView.clipsToBounds = YES;

    isOpen = NO;
    
    //[backgroundView addSubview:menuTable];
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self];
}

@end


