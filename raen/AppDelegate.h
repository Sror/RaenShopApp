//
//  AppDelegate.h
//  raen
//
//  Created by Alexey Ivanov on 13.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaenAPICommunicator.h"
#import "Socializer.h"

#import "RaenAPICommunicator.h"
#import "RaenAPICommunicatorDelegate.h"

extern NSString* RAENSHOP_CART_ITEMS;

@interface AppDelegate : UIResponder <UIApplicationDelegate,RaenAPICommunicatorDelegate>

@property (strong, nonatomic) UIWindow *window;


@end
