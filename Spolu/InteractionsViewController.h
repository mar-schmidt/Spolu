//
//  InteractionsViewController.h
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IRChatDataSourceManager.h"

@interface InteractionsViewController : UIViewController <ChatDataSourceManagerDelegate>
{

}

@property (nonatomic) NSInteger currentGroupConversationId;
@property (nonatomic, strong) UIView *circleView;


- (IBAction)showSidebar:(id)sender;
- (void)showStatusBar:(BOOL)show;

@end
