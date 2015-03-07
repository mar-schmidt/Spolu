//
//  InteractionsConversationsMenu.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#define GENERIC_IMAGE_FRAME CGRectMake(0, 0, 40, 40)
#define MENU_WIDTH 240

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "InteractionsConversationsMenu.h"
#import "UIView+Animation.h"




@implementation InteractionsConversationsMenu

- (instancetype)initFromViewController:(id)sender
{
    if ((self = [super init])) {
        // This is needed for the blurry background on menuTable
        
        _chatDataSourceManager = [IRChatDataSourceManager sharedChatDataSourceManager];
        [self commonInit:sender];
        
        _itemsArray = _chatDataSourceManager.conversationsDataSource;
        
        _itemsArray = [self sortArrayByDate:_itemsArray];
        
        [menuTable reloadData];
        
        // Register for new messages notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessageNotification:) name:@"newMessageReceived" object:nil];
    }
    return self;
}

- (NSArray *)sortArrayByDate:(NSArray *)array
{
    NSSortDescriptor *valueDescriptorGroup = [[NSSortDescriptor alloc] initWithKey:@"latestReceivedMessage" ascending:NO];
    
    NSArray *descriptors = @[valueDescriptorGroup];
    NSArray *sortedArray = [array sortedArrayUsingDescriptors:descriptors];
    
    return sortedArray;
}


#pragma mark IRWebSocketServiceHanderDelegate
- (void)didReceiveNewMessageNotification:(NSNotification *)notification
{
    if (self) {
        _itemsArray = _chatDataSourceManager.conversationsDataSource;
        [menuTable reloadData];
        
        // We need an unsorted copy of the array for the animation
        NSArray *unsortedConversationsArray = [_itemsArray copy];
        
        // Sort the elements and replace the array used by the data source with the sorted ones
        _itemsArray = [self sortArrayByDate:unsortedConversationsArray];
        
        // Prepare table for the animations batch
        [menuTable beginUpdates];
        
        // Move the cells around
        NSInteger sourceRow = 0;
        for (IRGroupConversation *groupConversation in unsortedConversationsArray) {
            NSInteger destRow = [_itemsArray indexOfObject:groupConversation];
            
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
    }
}


- (void)toggleMenu{
    if(!isOpen){
        [self show];
    } else {
        [self hide];
    }
}

- (void)show {
    if(!isOpen){
        [self.parent showStatusBar:NO];
        [menuTable reloadData];
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

#pragma -mark tableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_itemsArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IRGroupConversation *selectedGroupConversation = [_itemsArray objectAtIndex:indexPath.row];
    [self.delegate InteractionsConversationsMenu:self didSelectGroupConversation:selectedGroupConversation];
    
    UITableViewCell *cell = [menuTable cellForRowAtIndexPath:indexPath];
 
    /******
    *
    * TODO MORE ON
    *
    ******/
    CGRect cellFrame = cell.frame;
    cellFrame.origin.x = (self.parent.view.frame.size.width - cell.frame.size.width)/2;
    cellFrame.origin.y = self.parent.circleView.frame.origin.y-35;
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    
    [UIView animateWithDuration:0.3 animations:^{
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


#define MAIN_VIEW_TAG 1
#define TITLE_LABLE_TAG 2
#define IMAGE_VIEW_TAG 3

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"cell";
    UIView *circleView;
    UILabel *titleLabel;
    UIImageView *imageView;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    IRGroupConversation *conversation = [_itemsArray objectAtIndex:indexPath.row];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
        
        circleView = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width/2-65, 10, 130, 130)];
        circleView.tag = MAIN_VIEW_TAG;
        circleView.backgroundColor = [UIColor clearColor];
        circleView.layer.borderWidth = 1.5;
        circleView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
        circleView.layer.cornerRadius = circleView.bounds.size.height/2;
        circleView.clipsToBounds = YES;

        /*
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(85, 10.0, 120, 60)];
        titleLabel.tag = TITLE_LABLE_TAG;
        titleLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        titleLabel.font = [UIFont fontWithName:@"Avenir Next" size:16];
        
        [cell.contentView addSubview:titleLabel];
        */
        imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 130, 130)];
        imageView.tag = IMAGE_VIEW_TAG;
        
        [circleView addSubview:imageView];
        
        [cell.contentView addSubviewWithBounce:circleView];
        
        
    } else {
        
        circleView = (UIView *)[cell.contentView viewWithTag:MAIN_VIEW_TAG];
        titleLabel = (UILabel *)[cell.contentView viewWithTag:TITLE_LABLE_TAG];
        imageView = (UIImageView *)[cell.contentView viewWithTag:IMAGE_VIEW_TAG];
    }
    
    // If message is not read, set the border to red to notify the user that messages are not read
    for (IRMessageFrame *messageFrame in conversation.messages) {
        if (!messageFrame.message.readFlag) {
            circleView.layer.borderColor = [UIColor colorWithRed:255/255.0f green:0/255.0f blue:0/255.0f alpha:1.0f].CGColor;
            circleView.layer.borderWidth = 2.5;
        } else {
            circleView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
            circleView.layer.borderWidth = 1.5;
        }
    }
    
    //titleLabel.text = item.title;
    imageView.image = conversation.group.downloadedImage;
    return cell;
}

#pragma -mark Private helpers
- (void)commonInit:(UIViewController *)sender {
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    xAxis = 0;
    yAxis = 0;
    height = screenSize.size.height;
    width = MENU_WIDTH;
    
    self.frame = CGRectMake(-width, yAxis, width, height);
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
    
    gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(toggleMenu)];
    gesture.numberOfTapsRequired = 2;
    
    leftSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    
    rightSwipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(show)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    
    UIWindow *currentWindow = [UIApplication sharedApplication].keyWindow;
    [currentWindow addSubview:self];
    [sender.view addGestureRecognizer:gesture];
    [sender.view addGestureRecognizer:rightSwipe];
    [sender.view addGestureRecognizer:leftSwipe];
}

@end


