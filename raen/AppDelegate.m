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

@implementation AppDelegate


+(AppDelegate*)instance {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"didFinishLaunchingWithOptions");
    self.communicator = [[RaenAPICommunicator alloc]init];
    self.socializer = [[Socializer alloc] init];
    NSLog(@"socializer is auth ?%@",self.socializer.isAuthorizedViaSocial ? @"YES":@"NO");
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"application openURL %@ from sourceApplication %@",url,sourceApplication);
    BOOL wasHandled = NO;
    if ([[url absoluteString] rangeOfString:@"vk4237186"].location !=NSNotFound) {
        wasHandled = [VKSdk processOpenURL:url fromApplication:sourceApplication];
    }
    if ([[url absoluteString] rangeOfString:@"fb220082361532667"].location !=NSNotFound) {
        // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
        
        wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:self.socializer.fbSession];
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
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppCall handleDidBecomeActive];
    NSLog(@"applicationDidBecomeActive");
    [FBAppCall handleDidBecomeActiveWithSession:self.socializer.fbSession];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"applicationWillTerminate");
    [_communicator saveCookies];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"closing facebook session");
    [self.socializer.fbSession close];
}

@end
