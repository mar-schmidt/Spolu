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
#import "IRMessageFrame.h"
#import "IRMessage.h"
#import "IRImageViewDisplayer.h"
#import "IRMatchedGroupsDataSourceManager.h"
#import "IRWebSocketServiceHandler.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>
#import "InteractionsConversationsMenu.h"
#import "IRMatchServiceHandler.h"

@interface InteractionsViewController () <IRInputFunctionViewDelegate, IRMessageCellDelegate, UITableViewDataSource, UITableViewDelegate, InteractionsConversationsMenuDelegate>

@property (strong, nonatomic) MJRefreshHeaderView *head;
@property (strong, nonatomic) IRMatchedGroupsDataSourceManager *matchedGroupsDataSourceManager;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (nonatomic) InteractionsConversationsMenu *sideMenu;

@end

@implementation InteractionsViewController {
    IRInputFunctionView *IFView;
    BOOL _statusBarHidden;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

- (void)showStatusBar:(BOOL)show {
    [UIView animateWithDuration:0.3 animations:^{
        _statusBarHidden = !show;
        [self setNeedsStatusBarAppearanceUpdate];
    }];
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
    
    // Removing title from previous viewcontroller from the backbutton
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
                                                         forBarMetrics:UIBarMetricsDefault];
    
    [self addRefreshViews];
    [self loadBaseViewsAndData];
     
    _sideMenu = [[InteractionsConversationsMenu alloc] initFromViewController:self];
    _sideMenu.delegate = self;
    _sideMenu.parent = self;
}

/*
- (NSArray *)arrayOfMenuConversations:(NSArray *)conversations
{
    NSMutableArray *sideMenuItems;
    for (IRGroupConversation *conversation in conversations) {
        InteractionsConversationsMenuItem *item = [[InteractionsConversationsMenuItem alloc] initWithTitle:@"test" image:conversation.group.downloadedImage onCompletion:^(BOOL success, InteractionsConversationsMenuItem *item) {
            [sideMenuItems addObject:item];
        }];
    }
    return sideMenuItems;
}
*/
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Add notification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardChange:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(tableViewScrollToBottom) name:UIKeyboardDidShowNotification object:nil];
    
    IFView = [[IRInputFunctionView alloc] initWithSuperVC:self];
    IFView.delegate = self;
    [self.view addSubview:IFView];
    
    IFView.isAbleToSendTextMessage = YES;
    
    // Have an conversation up initially from currentConversationDataSource if it exist
    if (!_matchedGroupsDataSourceManager.currentConversationDataSource) {
        
        
        // Check if there actually are any conversations in conversationsDataSource. If not. We'll fetch existing conversations from backend
        NSLog(@"No current conversation exists in currentConversationsDataSource. Checking for existing converastions...");
        if (_matchedGroupsDataSourceManager.groupConversationsDataSource.count > 0) {
            NSLog(@"Existing conversations do exist, adding the first one to currentConversationsDataSource");
            _matchedGroupsDataSourceManager.currentConversationDataSource = _matchedGroupsDataSourceManager.groupConversationsDataSource[0];
        } else {
            // So no conversations exists locally. Lets fetch matches and see if there are any conversations to those matches
            NSLog(@"No existing conversations found locally. Checking backend for current matches which could have active conversations...");
            IRMatchServiceHandler *matchServiceHandler = [IRMatchServiceHandler sharedMatchServiceHandler];
            
            [matchServiceHandler getMatchesConversationsWithCompletionBlock:^(NSArray *groupConversations) {
                if (groupConversations && groupConversations.count > 0) {
                    
                    // There are matches. Adding them to matchedGroupsDataSource
                    NSLog(@"Matches found in backend! Adding these to matchedGroupsDataSource...");
                    IRMatchedGroupsDataSourceManager *matchedGroupsDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
                    matchedGroupsDataSourceManager.groupConversationsDataSource = [groupConversations mutableCopy];
                    
                    // Opening first conversation
                    _matchedGroupsDataSourceManager.currentConversationDataSource = _matchedGroupsDataSourceManager.groupConversationsDataSource[0];
                    
                    // Subscribe to all channels
                    IRWebSocketServiceHandler *webSocketHandler = [IRWebSocketServiceHandler sharedWebSocketHandler];
                    [webSocketHandler subscribeToAllAvailableChannels];
                } else {
                    NSLog(@"No matches found in backend...");
                    IFView.isAbleToSendTextMessage = NO;
                }

            } failure:^(NSError *error) {
                NSLog(@"Could not query backend for current matches. Exiting...");
            }];
            /*
            [matchServiceHandler getMatchesWithCompletionBlock:^(NSArray *groups) {
             
            } failure:^(NSError *error) {
             
            }];
             */
        }
    }
    
    [self setTitleImageFromConversation:_matchedGroupsDataSourceManager.currentConversationDataSource];
}

- (void)setTitleImageFromConversation:(IRGroupConversation *)conversation
{
    _circleView = [[UIView alloc]initWithFrame:CGRectMake(0,0,40,40)];
    _circleView.backgroundColor = [UIColor clearColor];
    _circleView.layer.borderWidth = 1;
    _circleView.layer.borderColor = [UIColor colorWithWhite:1 alpha:1].CGColor;
    _circleView.layer.cornerRadius = _circleView.bounds.size.height/2;
    _circleView.clipsToBounds = YES;
    
    
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:_matchedGroupsDataSourceManager.currentConversationDataSource.group.downloadedImage];
    titleImageView.contentMode = UIViewContentModeScaleAspectFill;
    titleImageView.frame = CGRectMake(2, 2, 39, 39);
    
    [_circleView addSubview:titleImageView];
    
    
    self.navigationItem.titleView = _circleView;
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
        
        if (weakSelf.matchedGroupsDataSourceManager.currentConversationDataSource.messages.count>pageNum) {
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
    
    _matchedGroupsDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
    _matchedGroupsDataSourceManager.delegate = self;
    
    //[self.chatModel populateRandomDataSource];
    
    
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
        [_sideMenu hide];
    } else {
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
    if (_matchedGroupsDataSourceManager.currentConversationDataSource.messages.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_matchedGroupsDataSourceManager.currentConversationDataSource.messages.count-1 inSection:0];
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
    message.from = IRMessageFromMe;
    message.strIcon = _matchedGroupsDataSourceManager.ownGroup.imageUrl;
    message.type = IRMessageTypeText;
    
    [self addMessageAndUpdateTable:message];
}

- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendPicture:(UIImage *)image
{
    // TEST NSDictionary *dic = @{@"picture": image, @"type":@(IRMessageTypePicture)};
    IRMessage *message = [[IRMessage alloc] init];
    message.picture = image;
    message.from = IRMessageFromMe;
    message.strIcon = _matchedGroupsDataSourceManager.ownGroup.imageUrl;
    message.type = IRMessageTypePicture;
    
    [self addMessageAndUpdateTable:message];
}

- (void)IRInputFunctionView:(IRInputFunctionView *)funcView sendVoice:(NSData *)voice time:(NSInteger)second
{
    // TEST NSDictionary *dic = @{@"voice": voice, @"strVoiceTime":[NSString stringWithFormat:@"%d",(int)second], @"type":@(IRMessageTypeVoice)};
    IRMessage *message = [[IRMessage alloc] init];
    message.voice = voice;
    message.from = IRMessageFromMe;
    message.strIcon = _matchedGroupsDataSourceManager.ownGroup.imageUrl;
    message.strVoiceTime = [NSString stringWithFormat:@"%d",(int)second];
    message.type = IRMessageTypeVoice;
    
    [self addMessageAndUpdateTable:message];
}


#pragma IRChatDataSourceManager delegate methods
- (void)matchedGroupsDataSourceManager:(IRMatchedGroupsDataSourceManager *)manager didReceiveMessages:(NSArray *)messages inGroupChat:(IRGroupConversation *)groupChat
{
    NSArray *messageArray = @[messages];
    //[self.chatDataSourceManager receivedMessages:messageArray fromMatchedGroup:group];
    
    /****
     * Only for test, set currentGroupConversation of chatDataSourceManagers conversationDataSource array to 1
     * in reality, this will be set by the controller that manages which conversation the user is clicking on
     ****/
    if (!_matchedGroupsDataSourceManager.currentConversationDataSource) {
        _matchedGroupsDataSourceManager.currentConversationDataSource = _matchedGroupsDataSourceManager.groupConversationsDataSource[0];
    }
    
    if (_matchedGroupsDataSourceManager.currentConversationDataSource.messages.count>=messageArray.count) {
        //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.chatTableView reloadData];
            NSIndexPath *totalRowsIndexPath = [NSIndexPath indexPathForRow:_matchedGroupsDataSourceManager.currentConversationDataSource.messages.count-1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:totalRowsIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void)addMessageAndUpdateTable:(IRMessage *)message
{
    [_matchedGroupsDataSourceManager sendMessage:message forGroupConversation:_matchedGroupsDataSourceManager.currentConversationDataSource];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _matchedGroupsDataSourceManager.currentConversationDataSource.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IRMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[IRMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:_matchedGroupsDataSourceManager.currentConversationDataSource.messages[indexPath.row]];
    
    // Mark the message (cell) as read.
    if (!cell.messageFrame.message.readFlag) {
        cell.messageFrame.message.readFlag = YES;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [_matchedGroupsDataSourceManager.currentConversationDataSource.messages[indexPath.row] cellHeight];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

#pragma mark - cellDelegate
- (void)headImageDidClick:(IRMessageCell *)cell image:(UIImage *)image {
    // headIamgeIcon is clicked
    [self.view endEditing:YES];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    //[imageView setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"chatfrom_doctor_icon"]];
    
    [IRImageViewDisplayer showImage:imageView];
    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Tip" message:@"HeadImageClick !!!" delegate:nil cancelButtonTitle:@"sure" otherButtonTitles:nil];
    //[alert show];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)showSidebar:(id)sender {
    [_sideMenu toggleMenu];
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}

#pragma mark InteractionsConversationsMenuDelegate methods
-(void)InteractionsConversationsMenu:(InteractionsConversationsMenu *)menu didSelectGroupConversation:(IRGroupConversation *)conversation {
    // Set the currentconversation to the one clicked on in InteractionsConversationsMenu
    _matchedGroupsDataSourceManager.currentConversationDataSource = conversation;
    
    // Reload tableview and scroll down to latest message
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
    
    [self setTitleImageFromConversation:conversation];
}

@end
