//
//  InteractionsViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "InteractionsViewController.h"
#import "IRInputFunctionView.h"
#import "MJRefresh.h"
#import "IRMessageCell.h"
#import "InteractionsChatModel.h"
#import "IRMessageFrame.h"
#import "IRMessage.h"
#import "IRImageViewDisplayer.h"
#import "IRMatchedGroups.h"
#import "IRWebSocketServiceHandler.h"

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "BTSimpleSideMenu.h"

@interface InteractionsViewController () <IRInputFunctionViewDelegate, IRMessageCellDelegate, UITableViewDataSource, UITableViewDelegate, WebSocketServiceHandlerDelegate, BTSimpleSideMenuDelegate>

@property (strong, nonatomic) MJRefreshHeaderView *head;
@property (strong, nonatomic) IRChatDataSourceManager *chatDataSourceManager;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic) BTSimpleSideMenu *sideMenu;

@end

@implementation InteractionsViewController {
    IRInputFunctionView *IFView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Nav bar more blur
    UIColor *barColour = self.navigationController.navigationBar.backgroundColor;
    UIView *colourView = [[UIView alloc] initWithFrame:CGRectMake(0.f, -20.f, 320.f, 64.f)];
    colourView.opaque = NO;
    colourView.alpha = .4f;
    colourView.backgroundColor = barColour;
    self.navigationController.navigationBar.barTintColor = barColour;
    [self.navigationController.navigationBar.layer insertSublayer:colourView.layer atIndex:1];
    
    [self addRefreshViews];
    [self loadBaseViewsAndData];
    
    
    BTSimpleMenuItem *item1 = [[BTSimpleMenuItem alloc]initWithTitle:@"One"
                                                               image:[UIImage imageNamed:@"icon1.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 1");
                                                        }];
    
    BTSimpleMenuItem *item2 = [[BTSimpleMenuItem alloc]initWithTitle:@"Two"
                                                               image:[UIImage imageNamed:@"icon2.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 2");
                                                        }];
    
    BTSimpleMenuItem *item3 = [[BTSimpleMenuItem alloc]initWithTitle:@"Three"
                                                               image:[UIImage imageNamed:@"icon3.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 3");
                                                        }];
    
    BTSimpleMenuItem *item4 = [[BTSimpleMenuItem alloc]initWithTitle:@"Four"
                                                               image:[UIImage imageNamed:@"icon4.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            NSLog(@"I am Item 4");
                                                        }];
    
    BTSimpleMenuItem *item5 = [[BTSimpleMenuItem alloc]initWithTitle:@"Five"
                                                               image:[UIImage imageNamed:@"icon5.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 5");
                                                        }];
    
    BTSimpleMenuItem *item6 = [[BTSimpleMenuItem alloc]initWithTitle:@"Six"
                                                               image:[UIImage imageNamed:@"icon6.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 6");
                                                        }];
    
    BTSimpleMenuItem *item7 = [[BTSimpleMenuItem alloc]initWithTitle:@"Seven"
                                                               image:[UIImage imageNamed:@"icon7.png"]
                                                        onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
                                                            
                                                            NSLog(@"I am Item 7");
                                                            
                                                        }];
    
    _sideMenu = [[BTSimpleSideMenu alloc] initWithItem:[self arrayOfMenuConversations:_chatDataSourceManager.conversationsDataSource]
                                 addToViewController:self];
    _sideMenu.delegate = self;
}

- (NSArray *)arrayOfMenuConversations:(NSArray *)conversations
{
    NSMutableArray *sideMenuItems;
    for (IRGroupConversation *conversation in conversations) {
        BTSimpleMenuItem *item = [[BTSimpleMenuItem alloc] initWithTitle:@"test" image:conversation.group.downloadedImage onCompletion:^(BOOL success, BTSimpleMenuItem *item) {
            [sideMenuItems addObject:item];
        }];
    }
    return sideMenuItems;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addRefreshViews
{
    __weak typeof(self) weakSelf = self;
    
    //load more
    int pageNum = 3;
    
    _head = [MJRefreshHeaderView header];
    _head.scrollView = self.chatTableView;
    _head.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        //[weakSelf.chatDataSourceManager addRandomItemsToDataSource:pageNum];
        
        if (weakSelf.chatDataSourceManager.currentConversationDataSource.messages.count>pageNum) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:pageNum inSection:0];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.chatTableView reloadData];
                [weakSelf.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
            });
        }
        [weakSelf.head endRefreshing];
    };
}

- (void)loadBaseViewsAndData
{
    self.chatTableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    
    _chatDataSourceManager = [IRChatDataSourceManager sharedChatDataSourceManager];
    _chatDataSourceManager.delegate = self;
    
    //[self.chatModel populateRandomDataSource];
    
    IFView = [[IRInputFunctionView alloc] initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    [self.chatTableView reloadData];
}

-(void)keyboardChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGRect keyboardEndFrame;
    
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    
    //adjust ChatTableView's height
    if (notification.name == UIKeyboardWillShowNotification) {
        self.bottomConstraint.constant = keyboardEndFrame.size.height+40;
    }else{
        self.bottomConstraint.constant = 40;
    }
    
    [self.view layoutIfNeeded];
    
    //adjust IRInputFunctionView's originPoint
    CGRect newFrame = IFView.frame;
    newFrame.origin.y = keyboardEndFrame.origin.y - newFrame.size.height;
    IFView.frame = newFrame;
    
    [UIView commitAnimations];
    
}

//tableView Scroll to bottom
- (void)tableViewScrollToBottom
{
    if (self.chatDataSourceManager.currentConversationDataSource.messages.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatDataSourceManager.currentConversationDataSource.messages.count-1 inSection:0];
    [self.chatTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}


#pragma mark - InputFunctionViewDelegate
- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendMessage:(NSString *)msg
{
    // TEST NSDictionary *dic = @{@"strContent": msg, @"type":@(IRMessageTypeText)};
    funcView.TextViewInput.text = @"";
    [funcView changeSendBtnWithPhoto:YES];
    
    IRMessage *message = [[IRMessage alloc] init];
    message.strContent = msg;
    message.type = IRMessageTypeText;
    
    [self addMessageAndUpdateTable:message];
}

- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    // TEST NSDictionary *dic = @{@"picture": image, @"type":@(IRMessageTypePicture)};
    IRMessage *message = [[IRMessage alloc] init];
    message.picture = image;
    message.type = IRMessageTypePicture;
    
    [self addMessageAndUpdateTable:message];
}

- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    // TEST NSDictionary *dic = @{@"voice": voice, @"strVoiceTime":[NSString stringWithFormat:@"%d",(int)second], @"type":@(IRMessageTypeVoice)};
    IRMessage *message = [[IRMessage alloc] init];
    message.voice = voice;
    message.strVoiceTime = [NSString stringWithFormat:@"%d",(int)second];
    message.type = IRMessageTypeVoice;
    
    [self addMessageAndUpdateTable:message];
}


#pragma IRChatDataSourceManager delegate methods
- (void)chatDataSourceManager:(IRChatDataSourceManager *)manager didReceiveMessages:(NSArray *)messages inGroupChat:(IRGroupConversation *)groupChat
{
    NSArray *messageArray = @[messages];
    //[self.chatDataSourceManager receivedMessages:messageArray fromMatchedGroup:group];
    
    /****
     * Only for test, set currentGroupConversation of chatDataSourceManagers conversationDataSource array to 1
     * in reality, this will be set by the controller that manages which conversation the user is clicking on
     ****/
    if (!_chatDataSourceManager.currentConversationDataSource) {
        _chatDataSourceManager.currentConversationDataSource = _chatDataSourceManager.conversationsDataSource[0];
    }
    
    if (self.chatDataSourceManager.currentConversationDataSource.messages.count>=messageArray.count) {
        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.chatTableView reloadData];
            NSIndexPath *totalRowsIndexPath = [NSIndexPath indexPathForRow:self.chatDataSourceManager.currentConversationDataSource.messages.count-1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:totalRowsIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void)addMessageAndUpdateTable:(IRMessage *)message
{
    [self.chatDataSourceManager sendMessage:message forGroupConversation:_chatDataSourceManager.currentConversationDataSource];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatDataSourceManager.currentConversationDataSource.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IRMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[IRMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.chatDataSourceManager.currentConversationDataSource.messages[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.chatDataSourceManager.currentConversationDataSource.messages[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(IRMessageCell *)cell imageUrl:(NSString *)url {
    // headIamgeIcon is clicked
    [self.view endEditing:YES];
    
    UIImageView *imageView = [[UIImageView alloc] init];
    [imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"chatfrom_doctor_icon"]];
    
    [IRImageViewDisplayer showImage:imageView];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"HeadImageClick !!!" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    //[alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showSidebar:(id)sender {
    [_sideMenu updateDataSourceWithArray:_chatDataSourceManager.conversationsDataSource];
    [_sideMenu toggleMenu];
}

#pragma -mark BTSimpleSideMenuDelegate

-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu didSelectItemAtIndex:(NSInteger)index {
    NSLog(@"Item Cliecked : %ld", (long)index);
}

-(void)BTSimpleSideMenu:(BTSimpleSideMenu *)menu selectedItemTitle:(NSString *)title {
    
}
@end
