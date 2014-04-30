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

#import "GAI.h"
#import "GAIDictionaryBuilder.h"


#define kGoogleAnalyticsTrackingId @"UA-50455989-1"

NSString *RAENSHOP_CART_ITEMS = @"RAENSHOP_CART_ITEMS";

@implementation AppDelegate 


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions %@",launchOptions);
    // Create a tab bar and set it as root view for the application
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
    tabController.delegate = self;
   
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

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"application openURL %@ from sourceApplication %@",url,sourceApplication);
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
    if ([[url absoluteString] rangeOfString:@"ru.raen.raenapp"].location !=NSNotFound) {
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
    NSLog(@"applicationDidBecomeActive");
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
    [FBAppCall handleDidBecomeActiveWithSession:[Socializer sharedManager].fbSession];
    NSLog(@"_fbSession %@",[Socializer sharedManager].fbSession);
                            
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"closing facebook session");
    [[Socializer sharedManager].fbSession close];
}

#pragma mark -UITabBarController Delegate

-(NSUInteger)tabBarControllerSupportedInterfaceOrientations:(UITabBarController *)tabBarController{
    return  UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)tabBarControllerPreferredInterfaceOrientationForPresentation:(UITabBarController *)tabBarController{
    return UIInterfaceOrientationPortrait;
}

@end
