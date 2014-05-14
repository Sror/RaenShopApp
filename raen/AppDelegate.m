//
//  AppDelegate.m
//  raen
//
//  Created by Alexey Ivanov on 13.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "VKSdk.h"
#import <GooglePlus/GooglePlus.h>
#import <Parse/Parse.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#define kParseAppID @"DI69ptupCemz4QCHiKXpwfI91GSQxGNWVkaDvsWN"
#define kParseClientKey @"kbHgEqCA4TFab1oXOnmtOZO6TtvNnG2Tero1O230"
#define kGoogleAnalyticsTrackingId @"UA-50455989-1"

NSString *RAENSHOP_CART_ITEMS = @"RAENSHOP_CART_ITEMS";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    // Create a tab bar and set it as root view for the application
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
    tabController.delegate = self;
    
    //PARSE.com
    [Parse setApplicationId:kParseAppID
                  clientKey:kParseClientKey];
    
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge|
     UIRemoteNotificationTypeAlert|
     UIRemoteNotificationTypeSound];
    
    //google analytics
    // Optional: automatically send uncaught exceptions to Google Analytics.
    [GAI sharedInstance].trackUncaughtExceptions = YES;
    // Optional: set Google Analytics dispatch interval to e.g. 20 seconds.
    [GAI sharedInstance].dispatchInterval = 20;
    // Optional: set debug to YES for extra debugging information.
   // [GAI sharedInstance].debug = YES;
    // Create tracker instance.
    id<GAITracker> tracker = [[GAI sharedInstance] trackerWithTrackingId:kGoogleAnalyticsTrackingId];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"App"
                                                         action:@"Запустил приложение"
                                                           label:nil
                                                           value:nil] build]];
    
   // [self updateCartBadge];
    return YES;
}
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
// iOS 6 autorotation fix
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"app open URL %@",url);
    BOOL wasHandled = NO;
    //VK.com
    if ([[url absoluteString] rangeOfString:@"vk4237186"].location !=NSNotFound) {
        wasHandled = [VKSdk processOpenURL:url fromApplication:sourceApplication];
    }
    //Facebook.com
    if ([[url absoluteString] rangeOfString:@"fb220082361532667"].location !=NSNotFound) {
        // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
        wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[Socializer sharedManager].fbSession];
    }
    //Google
    if ([[url absoluteString] rangeOfString:@"ru.alexeyivanov.raenapp"].location !=NSNotFound) {
        wasHandled = [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    
    return wasHandled;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
    [FBAppCall handleDidBecomeActiveWithSession:[Socializer sharedManager].fbSession];
    

                            
}

- (void)applicationWillTerminate:(UIApplication *)application
{

    [[Socializer sharedManager].fbSession close];

}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification %@",userInfo);
    [PFPush handlePush:userInfo];
    [PFAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
}


#pragma mark -UITabBarController Delegate
-(NSUInteger)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController{
    return  UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)tabBarControllerPreferredInterfaceOrientationForPresentation:(UITabBarController *)tabBarController{
    return UIInterfaceOrientationPortrait;
}

@end
