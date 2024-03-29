//
//  InteractionsConversationsMenu.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRMatchedGroupsDataSourceManager.h"
#import "IRGroupConversation.h"
#import "InteractionsViewController.h"
#import "UITableView+LongPress.h"

@class InteractionsConversationsMenu;

@protocol InteractionsConversationsMenuDelegate <NSObject>

@optional
-(void)InteractionsConversationsMenu:(InteractionsConversationsMenu *)menu didSelectGroupConversation:(IRGroupConversation *)conversation;

@end

@interface InteractionsConversationsMenu : UIView <UITableViewDelegate, UITableViewDataSource, UITableViewDelegateLongPress> {
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

@property(nonatomic, weak) id <InteractionsConversationsMenuDelegate> delegate;
@property (nonatomic, retain) NSArray *titleArray;
@property (nonatomic, retain) NSArray *imageArray;
@property (nonatomic, retain) NSMutableArray *itemsArray;

// To use for hiding and showing status bar in viewcontroller
@property (nonatomic, strong) InteractionsViewController *parent;

@property (strong, nonatomic) IRMatchedGroupsDataSourceManager *matchedGroupsDataSourceManager;

- (instancetype)initFromViewController:(id)sender;

-(void)show;
-(void)hide;
-(void)toggleMenu;
@end
