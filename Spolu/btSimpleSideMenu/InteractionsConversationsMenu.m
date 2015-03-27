//
//  InteractionsConversationsMenu.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#define MENU_WIDTH 230

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "InteractionsConversationsMenu.h"
#import "UIView+Animation.h"
#import "InteractionsConversationsMenuCell.h"
#import "IRImageViewDisplayer.h"


@implementation InteractionsConversationsMenu

- (instancetype)initFromViewController:(id)sender
{
    if ((self = [super init])) {
        _matchedGroupsDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
        [self commonInit:sender];
        
        //_chatDataSourceManager.conversationsDataSource = [self sortArrayByDate:_chatDataSourceManager.conversationsDataSource];
        
        [menuTable reloadData];
        
        // Register for new messages notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessageNotification:) name:@"newMessageReceived" object:nil];
        
        // Register for new matches notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMatch:) name:@"newMatchReceived" object:nil];
        
        // Add long press recognizer
        [menuTable addLongPressRecognizer];
    }
    return self;
}

- (NSMutableArray *)sortArrayByDate:(NSMutableArray *)array
{
    NSSortDescriptor *valueDescriptorGroup = [[NSSortDescriptor alloc] initWithKey:@"latestReceivedMessage" ascending:NO];
    
    NSArray *descriptors = @[valueDescriptorGroup];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:descriptors];
    
    return [sortedArray mutableCopy];
}


#pragma mark IRWebSocketServiceHanderDelegate
- (void)didReceiveNewMessageNotification:(NSNotification *)notification
{
    if (self) {
        [self sortAndReloadTableView];
    }
}

- (void)didReceiveNewMatch:(NSNotification *)notification
{
    if (self) {
        [self sortAndReloadTableView];
    }
}

- (void)sortAndReloadTableView
{
    // We need an unsorted copy of the array for the animation
    NSMutableArray *unsortedArray = [_matchedGroupsDataSourceManager.groupConversationsDataSource copy];
    
    [menuTable reloadData];
    
    // Sort the elements and replace the array used by the data source with the sorted ones
    _matchedGroupsDataSourceManager.groupConversationsDataSource = [self sortArrayByDate:unsortedArray];
    
    // Prepare table for the animations batch
    [menuTable beginUpdates];
    
    // Move the cells around
    NSInteger sourceRow = 0;
    for (IRGroupConversation *groupConversation in unsortedArray) {
        NSInteger destRow = [_matchedGroupsDataSourceManager.groupConversationsDataSource indexOfObject:groupConversation];
        
        if (destRow != sourceRow) {
            // Move the rows within the table view
            NSIndexPath *sourceIndexPath = [NSIndexPath indexPathForItem:sourceRow inSection:0];
            NSIndexPath *destIndexPath = [NSIndexPath indexPathForItem:destRow inSection:0];
            [menuTable moveRowAtIndexPath:sourceIndexPath toIndexPath:destIndexPath];
        }
        sourceRow++;
    }
    
    // Commit animations
    [menuTable endUpdates];
    
    // Otherwise crash...
    if (_matchedGroupsDataSourceManager.groupConversationsDataSource.count > 0) {
        [menuTable scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath
      toIndexPath:(NSIndexPath *)toIndexPath
{

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
            [self sortAndReloadTableView];
            
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

#pragma -mark tableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_matchedGroupsDataSourceManager.groupConversationsDataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IRGroupConversation *selectedGroupConversation = [_matchedGroupsDataSourceManager.groupConversationsDataSource objectAtIndex:indexPath.row];
    
    NSLog(@"Selected groupId %ld", (long)selectedGroupConversation.group.groupId);
    
    [self.delegate InteractionsConversationsMenu:self didSelectGroupConversation:selectedGroupConversation];
    
    InteractionsConversationsMenuCell *cell = (InteractionsConversationsMenuCell *)[menuTable cellForRowAtIndexPath:indexPath];
 
    /******
    *
    * Animation
    *
    ******/
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    CGRect screenSize = [UIScreen mainScreen].bounds;
    CGRect cellFrame = cell.bounds;
    cellFrame.origin.x = screenSize.size.width/2 - 100;
    cellFrame.origin.y = self.parent.circleView.bounds.origin.y-20;
    
    
    [UIView animateWithDuration:0.2 animations:^{
        [currentWindow addSubview:cell];
        cell.frame = cellFrame;
        cell.alpha = 0.3;
        cell.transform = CGAffineTransformMakeScale(0.3,0.3);
    } completion:^(BOOL finished) {
        cell.transform = CGAffineTransformIdentity;
        [cell removeFromSuperview];
    }];
    
    [self hide];
    
    [menuTable deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    InteractionsConversationsMenuCell *cell = (InteractionsConversationsMenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[InteractionsConversationsMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Set cells placeholder image
    cell.groupImageView.image = [UIImage imageNamed:@"chatfrom_doctor_icon"];
    
    IRGroupConversation *groupConversation = ((IRGroupConversation * )_matchedGroupsDataSourceManager.groupConversationsDataSource[indexPath.row]);
    if (groupConversation.group.downloadedImage) {
        // set the image
        cell.groupImageView.image = groupConversation.group.downloadedImage;
    }
    
    // If message is not read, set the border to red to notify the user that messages are not read
    for (IRMessageFrame *messageFrame in groupConversation.messages) {
        if (!messageFrame.message.readFlag) {
            cell.circleView.layer.borderColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1].CGColor;
            cell.circleView.layer.borderWidth = 2.0;
        } else {
            cell.circleView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            cell.circleView.layer.borderWidth = 1.5;
        }
    }
    
    // Set the latestRecievedMessage label
    NSString *dateString = [NSDateFormatter localizedStringFromDate:groupConversation.latestReceivedMessage
                                                          dateStyle:NSDateFormatterNoStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    // There are messages. Set the latest
    cell.latestMessageReceived.text = dateString;
    
    
    // Set the name of the group
    cell.groupNameLabel.text = groupConversation.group.name;
    
    // Set the text of messageLabel depending on if there are messages or just a match
    if (groupConversation.messages.count > 0) {
        // There are messages. Set the latest
        IRMessageFrame *messageFrame = groupConversation.messages.lastObject;
        if (messageFrame.message.strContent) {
            cell.messageMatchLabel.text = messageFrame.message.strContent;
        } else if (messageFrame.message.picture) {
            cell.messageMatchLabel.text = @"Sent an image";
        } else if (messageFrame.message.voice) {
            cell.messageMatchLabel.text = @"Sent a voice message";
        }
        
        // Is it unread? Then make its color green, otherwise gray
        if (!messageFrame.message.readFlag) {
            cell.messageMatchLabel.textColor = [UIColor colorWithRed:51/255.0f green:105/255.0f blue:30/255.0f alpha:1];
        } else {
            cell.messageMatchLabel.textColor = [UIColor lightGrayColor];
        }
    } else {
        // So there are no messages. Set messageMatchLabel.text to match
        cell.messageMatchLabel.text = @"New match!";
        cell.messageMatchLabel.textColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didRecognizeLongPressOnRowAtIndexPath:(NSIndexPath *)indexPath
{
    IRGroupConversation *groupConversation = ((IRGroupConversation * )_matchedGroupsDataSourceManager.groupConversationsDataSource[indexPath.row]);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:groupConversation.group.downloadedImage];
    
    [IRImageViewDisplayer showImage:imageView];
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
    
    menuTable = [[UITableView alloc]initWithFrame:CGRectMake(xAxis, yAxis, width, height) style:UITableViewStyleGrouped];
 
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

    [menuTable setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [menuTable setShowsVerticalScrollIndicator:NO];
    
    menuTable.backgroundColor = [UIColor clearColor];
    menuTable.delegate = self;
    menuTable.dataSource = self;

    isOpen = NO;
    
    [backgroundView addSubview:menuTable];
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self];
}

@end


