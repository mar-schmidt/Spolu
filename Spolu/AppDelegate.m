//
//  AppDelegate.m
//  Spolu
//
//  Created by Marcus Ronélius on 2015-02-20.
//  Copyright (c) 2015 Spolu Apps. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "IRWebSocketServiceHandler.h"
#import "IRChatDataSourceManager.h"
#import "MRInstallation.h"
#import "MRPush.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Fabric with crashlyrics
    [Fabric with:@[CrashlyticsKit]];
    
    IRChatDataSourceManager *chatDataSource = [IRChatDataSourceManager sharedChatDataSourceManager];
    IRWebSocketServiceHandler *websocket = [IRWebSocketServiceHandler sharedWebSocketHandler];
    websocket.delegate = chatDataSource;
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] >= 8)
    {
        UIUserNotificationSettings* notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notificationSettings];
        
        //register to receive notifications
        [application registerForRemoteNotifications];
    }
    else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound|UIRemoteNotificationTypeBadge)];
    }
    
    // Check for options
    if (launchOptions != nil) {
        // Handle data from the push.
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
            // Do whatever you need
            [MRPush handlePush:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
            application.applicationIconBadgeNumber = 0;
        }
    }
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    MRInstallation *currentInstallation = [MRInstallation currentInstallation];
    currentInstallation.deviceTokenFromData = deviceToken;
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    /*
    if (application.applicationState == UIApplicationStateInactive) {
        
    }
     */
    [MRPush handlePush:userInfo];
    application.applicationIconBadgeNumber = 0;
    
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    /*
    if (_receivedUserInfo != nil) {
        //Do whatever you need
     NSDictionary *aps = _receivedUserInfo[@"aps"];
     NSInteger groupId = [_receivedUserInfo[@"id"] integerValue];
     NSString *alertMessage = aps[@"alert"];
     NSLog(@"Push Notification: %@ from group %ld", alertMessage, groupId);
     application.applicationIconBadgeNumber = 0;
     _receivedUserInfo = nil;
    }
     */
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
