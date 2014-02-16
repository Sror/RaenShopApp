//
//  RaenAPICommunicator.h
//  raenapp
//
//  Created by Alexey Ivanov on 14.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RaenAPICommunicatorDelegate.h"

@class RaenAPICommunicator;

@interface RaenAPICommunicator : NSObject 
@property (weak, nonatomic) id<RaenAPICommunicatorDelegate> delegate;

- (void)getAllCategories;
- (void)getSubcategoryWithId:(NSString*)subcategoryId;
- (void)getItemCardWithId:(NSString*)itemId;
//cart
- (void)getItemsFromCart;

@end
