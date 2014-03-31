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

extern NSString* RAENSHOP_CART_ITEMS;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) RaenAPICommunicator *communicator;
@property (strong, nonatomic) Socializer *socializer;

+(AppDelegate*)instance;

@end
