//
//  RaenAPICommunicator.h
//  raenapp
//
//  Created by Alexey Ivanov on 14.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RaenAPICommunicatorDelegate.h"
#import "ItemModel.h"

@class RaenAPICommunicator;

@interface RaenAPICommunicator : NSObject 
@property (weak, nonatomic) id<RaenAPICommunicatorDelegate> delegate;


- (void)getNewsByPage:(NSInteger)page;
- (void)getAllCategories;
- (void)getSubcategoryWithId:(NSString*)subcategoryId;
- (void)getItemCardWithId:(NSString*)itemId;
- (void)getSliderItems;
- (void)getSaleOfDay;
//cart
- (void)getItemsFromCart;
- (void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty;
- (void)deleteItemFromCartWithID:(NSString*)id;
- (void)deleteCookieFromLocalStorage;
- (void)saveCookies;
- (void)restoreCookies;
- (void)deleteCookies;

@end
