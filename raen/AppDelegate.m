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



NSString *RAENSHOP_CART_ITEMS = @"RAENSHOP_CART_ITEMS";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions %@",launchOptions);
    //check which social signed
    //[[Socializer sharedManager] removeAuthDataFromDefaults];
    
    NSLog(@"currentSocial id %@",[[Socializer sharedManager] socialIdFromDefaults]);
    //check items count in cart and update tab bar badge
    /*
    NSArray *cartItems=[[NSUserDefaults standardUserDefaults] objectForKey:RAENSHOP_CART_ITEMS];
    NSLog(@"cartItems count %@",cartItems.count);
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [tabController.tabBar.items[2] setBadgeValue:[NSString stringWithFormat:@"%d",cartItems.count]];
    */
    [self updateCartBadge];
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
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    [[RaenAPICommunicator sharedManager] saveCookies];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"closing facebook session");
    [[Socializer sharedManager].fbSession close];
}

#pragma mark - RAEN API cummunitator methods
-(void)updateCartBadge{
    [RaenAPICommunicator sharedManager].delegate = self;
    [[RaenAPICommunicator sharedManager] getItemsFromCart];
}
#pragma mark - RAEN API Delegation methods
-(void)didReceiveCartItems:(NSArray *)items{
    UITabBarController *tabController = (UITabBarController *) self.window.rootViewController;
    [tabController.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%i",items.count]];
}
-(void)fetchingFailedWithError:(JSONModelError *)error{
    NSLog(@"error to update cart icon badge");
}
@end
