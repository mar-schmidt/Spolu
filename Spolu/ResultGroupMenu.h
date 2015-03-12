//
//  ResultGroupMenu.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultViewController.h"

@class ResultGroupMenu;

@protocol ResultGroupMenuDelegate <NSObject>

@optional
-(void)ResultGroupMenu:(ResultGroupMenu *)menu;

@end

@interface ResultGroupMenu : UIView <UITableViewDelegate, UITableViewDataSource> {
    @private
    UITableView *menuTable;
    CGFloat xAxis, yAxis,height, width;
    BOOL isOpen;
    UITapGestureRecognizer *gesture;
    UISwipeGestureRecognizer *leftSwipe, *rightSwipe;
    UIImage *blurredImage;
    UIImageView *backGroundImage;
    UIImage *screenShotImage;
    UIImageView *screenShotView;
}

@property(nonatomic, weak) id <ResultGroupMenuDelegate> delegate;
@property (nonatomic, retain) NSArray *titleArray;
@property (nonatomic, retain) NSArray *imageArray;
@property (nonatomic, retain) NSMutableArray *itemsArray;

// To use for hiding and showing status bar in viewcontroller
@property (nonatomic, strong) ResultViewController *parent;

- (instancetype)initFromViewController:(id)sender;

-(void)show;
-(void)hide;
-(void)toggleMenu;
@end
