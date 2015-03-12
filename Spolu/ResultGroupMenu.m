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
        [self commonInit:sender];
        
        [menuTable reloadData];
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

#pragma -mark tableView Delegates

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self hide];
    
    [menuTable deselectRowAtIndexPath:indexPath animated:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    /*
    if (!cell) {
        cell = [[InteractionsConversationsMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    // Set cells placeholder image
    cell.groupImageView.image = [UIImage imageNamed:@"chatfrom_doctor_icon"];
    
    IRGroupConversation *groupConversation = ((IRGroupConversation * )self.chatDataSourceManager.conversationsDataSource[indexPath.row]);
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
    */
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


