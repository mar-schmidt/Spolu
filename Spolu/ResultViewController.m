//
//  ResultViewController.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-21.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "ResultViewController.h"
#import "IRGroup.h"
#import "IRMatchedGroupsDataSourceManager.h"
#import "FilterViewController.h"
#import "ResultGroupMenu.h"

@interface ResultViewController () <ResultGroupMenuDelegate>

@property (nonatomic, strong) NSMutableArray *groups;
@property (nonatomic) ResultGroupMenu *sideMenu;


@property (nonatomic, weak) IBOutlet UIView *titleView;
@property (nonatomic, weak) IBOutlet UIButton *titleButton;
@property (nonatomic, weak) IBOutlet UIImageView *leftArrowView;
@property (nonatomic, weak) IBOutlet UIImageView *rightArrowView;

@end

@implementation ResultViewController
{
    BOOL _statusBarHidden;
    UIButton *buttonHideMenu;
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
    
    // Register for new messages notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNewMatch:) name:@"newMatchReceived" object:nil];
    
    // Init the matchServiceHandler singelton
    matchServiceHandler = [IRMatchServiceHandler sharedMatchServiceHandler];
    
    titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 200, self.navigationController.navigationBar.frame.size.height)];
    distanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 25)];
    ageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 23, 200, 15)];

    
    _sideMenu = [[ResultGroupMenu alloc] initFromViewController:self];
    _sideMenu.delegate = self;
    _sideMenu.parent = self;
    
    // Datasource should be populated with latest groups
    eligibleGroupsDataSource = [EligibleGroupsDataSource sharedEligibleGroupsDataSource];
    
    // Display the first ChooseGroupView in front. Users can swipe to indicate
    // whether they like or dislike the group displayed.
    self.frontCardView = [self popGroupViewWithFrame:[self frontCardViewFrame]];
    [self.view addSubview:self.frontCardView];
    
    // Display the second ChooseGroupView in back. This view controller uses
    // the MDCSwipeToChooseDelegate protocol methods to update the front and
    // back views after each user swipe.
    self.backCardView = [self popGroupViewWithFrame:[self backCardViewFrame]];
    [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
}

- (void)didReceiveNewMatch:(NSNotification *)notification
{
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor redColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    titleView.backgroundColor = [UIColor clearColor];
    
    distanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:18.f];
    distanceLabel.textAlignment = NSTextAlignmentCenter;
    distanceLabel.textColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    distanceLabel.adjustsFontSizeToFitWidth = YES;
    distanceLabel.minimumScaleFactor = 5;
    //distanceLabel.backgroundColor = [UIColor blueColor];
    
    ageLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:11.f];
    ageLabel.textAlignment = NSTextAlignmentCenter;
    ageLabel.textColor = [UIColor grayColor];
    ageLabel.adjustsFontSizeToFitWidth = YES;
    ageLabel.minimumScaleFactor = 5;
    //ageLabel.backgroundColor = [UIColor redColor];
    
    [titleView addSubview:distanceLabel];
    [titleView addSubview:ageLabel];
    
    self.navigationItem.titleView = titleView;
}

- (void)toggleMenu
{
    buttonHideMenu = [[UIButton alloc] initWithFrame:self.view.frame];
    [buttonHideMenu addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonHideMenu];
    
    // Disable rightBarbutton so that we cannot go into chat without closing the menu first
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [_sideMenu toggleMenu];
}

- (void)closeMenu
{
    buttonHideMenu.enabled = NO;
    self.navigationItem.rightBarButtonItem.enabled = YES;
    [_sideMenu toggleMenu];
}

#pragma mark - MDCSwipeToChooseDelegate Callbacks

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"Couldn't decide, huh?");
}

// Sent before a choice is made. Cancel the choice by returning `NO`. Otherwise return `YES`.
- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
    if (direction == MDCSwipeDirectionLeft || direction == MDCSwipeDirectionRight) {
        return YES;
    } else {
        // Snap the view back and cancel the choice.
        [UIView animateWithDuration:0.16 animations:^{
            view.transform = CGAffineTransformIdentity;
            view.center = self.view.superview.center;
        }];
        return NO;
    }
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    // MDCSwipeToChooseView shows "NOPE" on swipes to the left,
    // and "LIKED" on swipes to the right.
    
    if (direction == MDCSwipeDirectionLeft) {
        /*****
        *
        * Notify the backend about passing on this card (group)
        *
        ******/
        NSLog(@"You passed on group %ld.", (long)_currentGroup.groupId);
        
        // Adding this due to a shitty bug i cannot track. Take _currentGroup.groupId (since its correct) and point it to a new IRGroup instance which we will use for the async pass response block. Later we will get ID in the response which we can double check against.
        IRGroup *passedGroup = _currentGroup;

        [matchServiceHandler postPassForGroup:passedGroup withCompletionBlockSuccess:^(BOOL succeeded) {
            if (succeeded) {
                NSLog(@"Notified backend about passing group with id %ld", (long)passedGroup.groupId);
            }
        } failure:^(NSError *error) {
            NSLog(@"Error while notifying backend about passing this group");
        }];
        
    }
    
    else {
        /*****
        *
        * Send the current group to backend for matchchecking.
        *
        ******/
        NSLog(@"You liked %ld.", (long)_currentGroup.groupId);
        
        // Adding this due to a shitty bug i cannot track. Take _currentGroup.groupId (since its correct) and point it to a new IRGroup instance which we will use for the async like response block. Later we will get ID in the response which we can double check against.
        IRGroup *likedGroup = _currentGroup;

        [matchServiceHandler postLikeForGroup:likedGroup withCompletionBlockMatch:^(BOOL matching, NSString *channel) {
            if (matching) {
                // We got a match!
                NSLog(@"!!!!!!!!! Matched with group %ld !!!!!!!!!!!!", (long)likedGroup.groupId);
                // Add this match to matchingDataSource
                IRMatchedGroupsDataSourceManager *matchedGroupsDataSourceManager = [IRMatchedGroupsDataSourceManager sharedMatchedGroups];
                IRGroupConversation *newGroupConversation = [matchedGroupsDataSourceManager createNewGroupConversationWithMessage:nil fromGroup:likedGroup];

                // Add the channel to the groupConversation and subscribe to it
                newGroupConversation.conversationChannel = channel;
                
                IRWebSocketServiceHandler *webSocketServiceHandler = [IRWebSocketServiceHandler sharedWebSocketHandler];
                [webSocketServiceHandler subscribeToChannel:channel];
                
                [matchedGroupsDataSourceManager.groupConversationsDataSource addObject:newGroupConversation];

            } else {
                NSLog(@"No matching for group %ld", (long)likedGroup.groupId);
            }
        } failure:^(NSError *error) {
            NSLog(@"Error while requesting for match");
        }];
    }
    
    // MDCSwipeToChooseView removes the view from the view hierarchy
    // after it is swiped (this behavior can be customized via the
    // MDCSwipeOptions class). Since the front card view is gone, we
    // move the back card to the front, and create a new back card.
    self.frontCardView = self.backCardView;
    if ((self.backCardView = [self popGroupViewWithFrame:[self backCardViewFrame]])) {
        // Fade the back card into view.
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
}


#pragma mark - Internal Methods

- (void)setFrontCardView:(ChooseGroupView *)frontCardView {
    // Keep track of the group currently being chosen.
    // Quick and dirty, just for the purposes of this sample app.
    _frontCardView = frontCardView;
    _currentGroup = frontCardView.group;
    
    // Update navigation title with KM to group. If no new group is found, notify user about it
    if (_currentGroup) {
        distanceLabel.textColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
        distanceLabel.text = [NSString stringWithFormat:@"%ld km to group", (long)_currentGroup.distance];
        ageLabel.text = [NSString stringWithFormat:@"Around %ld years old", (long)_currentGroup.age];
        //NSLog(@"%@ - %@", titleView.distanceLabel.text, titleView.ageLabel.text);
        
        // Disable ability to go back (until 24hourse has gone by). Instead we show the user a menu with posivility to change settings
        UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] init];
        UIImage *image = [[UIImage imageNamed:@"chatfrom_doctor_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        menuItem.target = self;
        menuItem.action = @selector(toggleMenu);
        menuItem.image = image;
        self.navigationItem.leftBarButtonItem = menuItem;
    } else
    {
        distanceLabel.textColor = [UIColor grayColor];
        distanceLabel.text = @"No groups found";
        ageLabel.text = @"";
        
        // This will make the leftBarButtonItem show an exit. Allowing user to get back and change criterias
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(backToFilterViewController)];
    }
}

- (void)backToFilterViewController
{
    [self performSegueWithIdentifier:@"changeSettings" sender:self];
}

- (ChooseGroupView *)popGroupViewWithFrame:(CGRect)frame {
    // If our dataSource has less than 5, we want to start downloading new results
    if ([eligibleGroupsDataSource.dataSource count] == 1) {
        [matchServiceHandler getEligibleGroupsResultForGroup:nil];
    }
    
    if ([eligibleGroupsDataSource.dataSource count] == 0) {
        // retry nearby api call
        return nil;
    }
    
    // UIView+MDCSwipeToChoose and MDCSwipeToChooseView are heavily customizable.
    // Each take an "options" argument. Here, we specify the view controller as
    // a delegate, and provide a custom callback that moves the back card view
    // based on how far the user has panned the front card view.
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 100.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y - (state.thresholdRatio / 10.f),
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    
    // Create a groupView with the top group in the groups array, then pop
    // that group off the stack.
    ChooseGroupView *groupView = [[ChooseGroupView alloc] initWithFrame:frame
                                                                    group:eligibleGroupsDataSource.dataSource[0]
                                                                   options:options];
    [eligibleGroupsDataSource.dataSource removeObjectAtIndex:0];
    
    return groupView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 00.f;
    CGFloat topPadding = 00.f;
    CGFloat bottomPadding = 00.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding),
                      CGRectGetHeight(self.view.frame) - bottomPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y + 00.f,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}
/*
 // Create and add the "nope" button.
 - (void)constructNopeButton {
 UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 UIImage *image = [UIImage imageNamed:@"nope"];
 button.frame = CGRectMake(ChoosePersonButtonHorizontalPadding,
 CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
 image.size.width,
 image.size.height);
 [button setImage:image forState:UIControlStateNormal];
 [button setTintColor:[UIColor colorWithRed:247.f/255.f
 green:91.f/255.f
 blue:37.f/255.f
 alpha:1.f]];
 [button addTarget:self
 action:@selector(nopeFrontCardView)
 forControlEvents:UIControlEventTouchUpInside];
 [self.view addSubview:button];
 }
 
 // Create and add the "like" button.
 - (void)constructLikedButton {
 UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
 UIImage *image = [UIImage imageNamed:@"liked"];
 button.frame = CGRectMake(CGRectGetMaxX(self.view.frame) - image.size.width - ChoosePersonButtonHorizontalPadding,
 CGRectGetMaxY(self.backCardView.frame) + ChoosePersonButtonVerticalPadding,
 image.size.width,
 image.size.height);
 [button setImage:image forState:UIControlStateNormal];
 [button setTintColor:[UIColor colorWithRed:29.f/255.f
 green:245.f/255.f
 blue:106.f/255.f
 alpha:1.f]];
 [button addTarget:self
 action:@selector(likeFrontCardView)
 forControlEvents:UIControlEventTouchUpInside];
 [self.view addSubview:button];
 }
 */
#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showChat"]) {
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor colorWithRed:124/255.0f green:179/255.0f blue:66/255.0f alpha:1];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
