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

@interface InteractionsViewController () <IRInputFunctionViewDelegate, IRMessageCellDelegate, UITableViewDataSource, UITableViewDelegate, WebSocketServiceHandlerDelegate>

@property (strong, nonatomic) MJRefreshHeaderView *head;
@property (strong, nonatomic) InteractionsChatModel *chatModel;

@property (weak, nonatomic) IBOutlet UITableView *chatTableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

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
    
    // Register delegate of IRWebSocketServiceHandler
    webSocketHandler = [IRWebSocketServiceHandler sharedWebSocketHandler];
    webSocketHandler.delegate = self;
    
    [self addRefreshViews];
    [self loadBaseViewsAndData];
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
        
        [weakSelf.chatModel addRandomItemsToDataSource:pageNum];
        
        if (weakSelf.chatModel.dataSource.count>pageNum) {
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
    
    self.chatModel = [[InteractionsChatModel alloc] init];
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
    if (self.chatModel.dataSource.count==0)
        return;
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
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

- (void)webSocketServiceHandler:(IRWebSocketServiceHandler *)service didReceiveNewMessage:(IRMessage *)message fromGroup:(IRGroup *)group
{
    NSArray *messageArray = @[message];
    [self.chatModel receivedMessages:messageArray fromMatchedGroup:group];
    
    if (self.chatModel.dataSource.count>=messageArray.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[messageArray count]-1 inSection:0];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.chatTableView reloadData];
            NSIndexPath *totalRowsIndexPath = [NSIndexPath indexPathForRow:self.chatModel.dataSource.count-1 inSection:0];
            [self.chatTableView scrollToRowAtIndexPath:totalRowsIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    }
}

- (void)addMessageAndUpdateTable:(IRMessage *)message
{
    [self.chatModel sendMessage:message];
    [self.chatTableView reloadData];
    [self tableViewScrollToBottom];
}

#pragma mark - tableView delegate & datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.chatModel.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IRMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellID"];
    if (cell == nil) {
        cell = [[IRMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellID"];
        cell.delegate = self;
    }
    [cell setMessageFrame:self.chatModel.dataSource[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.chatModel.dataSource[indexPath.row] cellHeight];
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


@end
