//
//  InteractionsConversationsMenu.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InteractionsConversationsMenuItem.h"
#import "IRChatDataSourceManager.h"
#import "IRGroupConversation.h"

@class InteractionsConversationsMenu;

@protocol InteractionsConversationsMenuDelegate <NSObject>

@optional
-(void)InteractionsConversationsMenu:(InteractionsConversationsMenu *)menu didSelectGroupConversation:(IRGroupConversation *)conversation;
-(void)InteractionsConversationsMenu:(InteractionsConversationsMenu *)menu selectedItemTitle:(NSString *)title;

@end

@interface InteractionsConversationsMenu : UIView <UITableViewDelegate, UITableViewDataSource> {
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

@property (nonatomic, retain) InteractionsConversationsMenuItem *selectedItem;
@property(nonatomic, weak) id <InteractionsConversationsMenuDelegate> delegate;
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
