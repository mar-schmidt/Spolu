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

#pragma -mark public methods

-(instancetype) initWithItem:(NSArray *)items addToViewController:(id)sender {
    if ((self = [super init])) {
        // perform the other initialization of items.
        _chatDataSourceManager = [IRChatDataSourceManager sharedChatDataSourceManager];
        [self commonInit:sender];
        _itemsArray = [self arrayOfMenuConversations:_chatDataSourceManager.conversationsDataSource];
        //_itemsArray = items;
        menuTable.backgroundColor = [UIColor clearColor];
        
        // Register for new messages notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMessageNotification:) name:@"newMessageReceived" object:nil];
    }
    return self;
}

#pragma mark IRWebSocketServiceHanderDelegate
- (void)didReceiveNewMessageNotification:(NSNotification *)notification
{
    if (self) {
        [self updateDataSourceWithArray:_chatDataSourceManager.conversationsDataSource];
        [menuTable reloadData];
    }
}

-(instancetype)initWithItemTitles:(NSArray *)itemsTitle addToViewController:(UIViewController *)sender {
    
    if ((self = [super init])) {
        // perform the other initialization of items.
        [self commonInit:sender];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for(int i = 0;i<[itemsTitle count]; i++){
            InteractionsConversationsMenuItem *temp = [[InteractionsConversationsMenuItem alloc]initWithTitle:[itemsTitle objectAtIndex:i]
                                                                      image:nil onCompletion:nil];
            [tempArray addObject:temp];
        }
        _itemsArray = tempArray;
    }
    return self;
}

-(instancetype)initWithItemTitles:(NSArray *)itemsTitle andItemImages:(NSArray *)itemsImage addToViewController:(UIViewController *)sender{
    if ((self = [super init])) {
        // perform the other initialization of items.
        [self commonInit:sender];
        NSMutableArray *tempArray = [[NSMutableArray alloc]init];
        for(int i = 0;i<[itemsTitle count]; i++){
            InteractionsConversationsMenuItem *temp = [[InteractionsConversationsMenuItem alloc]initWithTitle:[itemsTitle objectAtIndex:i]
                                                                      image:[itemsImage objectAtIndex:i]
                                                               onCompletion:nil];
            [tempArray addObject:temp];
        }
        _itemsArray = tempArray;
    }
    return self;
}

- (void)updateDataSourceWithArray:(NSArray *)array
{
    _itemsArray = [self arrayOfMenuConversations:array];
}

- (NSArray *)arrayOfMenuConversations:(NSArray *)conversations
{
    NSMutableArray *sideMenuItems = [[NSMutableArray alloc] init];
    for (IRGroupConversation *conversation in conversations) {
        InteractionsConversationsMenuItem *item = [[InteractionsConversationsMenuItem alloc] initWithTitle:@"test" image:conversation.group.downloadedImage onCompletion:^(BOOL success, InteractionsConversationsMenuItem *item) {
            
        }];
        [sideMenuItems addObject:item];
    }
    return sideMenuItems;
}

-(void)toggleMenu{
    if(!isOpen){
        [self show];
    }else {
        [self hide];
    }
}

-(void)show {
    if(!isOpen){
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

-(void)hide {
    if(isOpen){
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //return [_itemsArray count];
    return [_chatDataSourceManager.conversationsDataSource count];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 160;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    IRGroupConversation *selectedGroupConversation = [_chatDataSourceManager.conversationsDataSource objectAtIndex:indexPath.row];
    [self.delegate InteractionsConversationsMenu:self didSelectGroupConversation:selectedGroupConversation];
    
    UITableViewCell *cell = [menuTable cellForRowAtIndexPath:indexPath];
    /*
    [UIView animateWithDuration:2 animations:^{
        cell.alpha = 0;
        cell.frame = CGRectMake(cell.frame.origin.x,
                                cell.frame.origin.y,
                                cell.frame.size.width*5,
                                cell.frame.size.height*4);
    }];
    */
    
    /******
    *
    * TODO MORE ON
    *
    ******/
    CGRect cellRightFrame = cell.frame;
    cellRightFrame.origin.x = menuTable.bounds.size.width;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    cell.alpha = 0;
    cell.transform = CGAffineTransformMakeScale(2,2);
    cell.frame = cellRightFrame;
    
    
    [UIView commitAnimations];
    
    
    _selectedItem = [_itemsArray objectAtIndex:indexPath.row];
    
    [self hide];
    
    cell.transform = CGAffineTransformIdentity;
    
    if (_selectedItem.block) {
        BOOL success= YES;
        _selectedItem.block(success, _selectedItem);
    }
    [menuTable deselectRowAtIndexPath:indexPath animated:NO];
}

#define MAIN_VIEW_TAG 1
#define TITLE_LABLE_TAG 2
#define IMAGE_VIEW_TAG 3

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier = @"cell";
    UIView *circleView;
    UILabel *titleLabel;
    UIImageView *imageView;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    InteractionsConversationsMenuItem *item = [_itemsArray objectAtIndex:indexPath.row];
    
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
    
    titleLabel.text = item.title;
    imageView.image = item.imageView.image;
    return cell;
}

#pragma -mark Private helpers
-(void)commonInit:(UIViewController *)sender{
    
    CGRect screenSize = [UIScreen mainScreen].bounds;
    xAxis = 0;
    yAxis = 0;
    height = screenSize.size.height;
    width = MENU_WIDTH;
    
    self.frame = CGRectMake(-width, yAxis, width, height);
    //self.backgroundColor = BACKGROUND_COLOR;
    if(!sender.navigationController.navigationBarHidden) {
        menuTable = [[UITableView alloc]initWithFrame:CGRectMake(xAxis, yAxis, width, height) style:UITableViewStyleGrouped];
    }else {
        menuTable = [[UITableView alloc]initWithFrame:CGRectMake(xAxis, yAxis, width, height) style:UITableViewStyleGrouped];
    }
 
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

-(UIImage *)reducedImage:(UIImage *)srcImage{
    UIImage *image = srcImage;
    UIImage *tempImage = nil;
    CGSize targetSize = CGSizeMake(20,20);
    UIGraphicsBeginImageContext(targetSize);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 0, 0);
    thumbnailRect.origin = CGPointMake(0.0,0.0);
    thumbnailRect.size.width  = targetSize.width;
    thumbnailRect.size.height = targetSize.height;
    
    [image drawInRect:thumbnailRect];
    
    tempImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return tempImage;

}

@end


