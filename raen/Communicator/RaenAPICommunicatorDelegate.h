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
- (void)didRemoveItemFromCartWithResponse:(NSDictionary*)response;

- (void)didReceiveFilter:(id)filter;
//authorization delegate methods
- (void)didSuccessAPIAuthorizedWithResponse:(NSDictionary*)response;
- (void)didEmailRequest;
- (void)didFailuerAPIAuthorizationWithResponse:(NSDictionary*)response;

@required
- (void)fetchingFailedWithError:(JSONModelError *)error;
@end
