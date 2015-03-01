//
//  BTSimpleSideMenu.h
//  BTSimpleSideMenuDemo
//
//  Created by Balram on 29/05/14.
//  Copyright (c) 2014 Balram Tiwari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BTSimpleMenuItem.h"
#import "IRChatDataSourceManager.h"

@class BTSimpleSideMenu;

@protocol BTSimpleSideMenuDelegate <NSObject>

@optional
-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu didSelectItemAtIndex:(NSInteger)index;
-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu selectedItemTitle:(NSString *)title;

@end

@interface BTSimpleSideMenu : UIView<UITableViewDelegate, UITableViewDataSource> {
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

@property (nonatomic, retain) BTSimpleMenuItem *selectedItem;
@property(nonatomic, weak) id <BTSimpleSideMenuDelegate> delegate;
@property (nonatomic, retain) NSArray *titleArray;
@property (nonatomic, retain) NSArray *imageArray;
@property (nonatomic, retain) NSArray *itemsArray;

@property (strong, nonatomic) IRChatDataSourceManager *chatDataSourceManager;

-(instancetype) initWithItem:(NSArray *)items addToViewController:(id)sender;
-(instancetype) initWithItemTitles:(NSArray *)itemsTitle addToViewController:(id)sender;
-(instancetype) initWithItemTitles:(NSArray *)itemsTitle andItemImages:(NSArray *)itemsImage addToViewController:(UIViewController *)sender;
- (void)updateDataSourceWithArray:(NSArray *)array;

-(void)show;
-(void)hide;
-(void)toggleMenu;
@end
