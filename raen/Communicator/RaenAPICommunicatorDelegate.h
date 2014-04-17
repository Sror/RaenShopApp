//
//  RaenAPICommunicatorDelegate.h
//  raenapp
//
//  Created by Alexey Ivanov on 14.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelError.h"


@protocol RaenAPICommunicatorDelegate <NSObject>
@optional
- (void)didReceiveNews:(NSArray*)news;
- (void)didReceiveCartItems:(NSArray *)items;
- (void)didAddItemToCartWithResponse:(NSDictionary*)response;
//- (void)didReceiveSubcategoryItems:(NSArray *)items;
- (void)didReceiveSubcategory:(id)subcategoryModel;
- (void)didReceiveItemCard:(id)itemCard;
- (void)didReceiveAllCategories:(NSArray *)array;
- (void)didReceiveSliderItems:(NSArray*)array;
- (void)didReceiveSaleOfDay:(id)saleOfDayModel;
- (void)didChangeCartItemQTYWithResponse:(NSDictionary*)response;
- (void)didFailureChangeCartItemQTYWithError:(JSONModelError*)error;
- (void)didFailureAddingItemToCartWithError:(JSONModelError*)error;
- (void)didReceiveFilter:(id)filter;
- (void)didCheckoutWithResponse:(NSDictionary*)response;
//authorization delegate methods
- (void)didSuccessAPIAuthorizedWithResponse:(NSDictionary*)response;
- (void)didEmailRequest;
- (void)didExistEmail;
- (void)didFailuerAPIAuthorizationWithResponse:(NSDictionary*)response;

- (void)didReceiveUserInfo:(NSDictionary*)userInfo;
- (void)didReceiveUserOrders:(NSDictionary*)userOrders;

@required
- (void)fetchingFailedWithError:(JSONModelError *)error;
@end
