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

extern int RaenAPIdefaulSubcategoryItemsCountPerPage;
extern int RaenAPIdefaultNewsItemsCountPerPage;

@class RaenAPICommunicator;

@interface RaenAPICommunicator : NSObject 
@property (weak, nonatomic) id<RaenAPICommunicatorDelegate> delegate;
@property (nonatomic,strong) NSString *raenAPIAccessToken;

//+ (RaenAPICommunicator*)sharedManager;

#pragma mark - News
- (void)getNewsByPage:(NSInteger)page;
- (void)getSliderItems;
#pragma mark - Shop
- (void)getAllCategories;
#pragma mark -Filters
- (void)getParamsOfCategoryWithId:(NSString*)categoryId;
#pragma mark - Grid items vc
- (void)getSubcategoryWithId:(NSString*)subcategoryId withParameters:(NSDictionary*)parameters;
#pragma mark - ItemCard
- (void)getItemCardWithId:(NSString*)itemId;
#pragma mark - SaleOfDay
- (void)getSaleOfDay;

#pragma mark - Cart
- (void)getItemsFromCart;
- (void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty;
- (void)changeCartItemQTY:(NSString*)qty byRowID:(NSString*)rowid;

#pragma  mark -Checkout
- (void)checkoutFastWithFirstName:(NSString*)firstName andPhone:(NSString*)phone;

//authorization methods
#pragma mark - RAEN API Authorization
-(void)authViaEmail:(NSString*)email andPassword:(NSString*)password;

- (void)authAPIVia:(NSString*)socialName
withuserIdentifier:(NSString*)userId
       accessToken:(NSString*)token
optionalParameters:(NSDictionary*)optionalParametersDictionary;

- (void)signInNewUserWithEmail:(NSString*)email
                           firstName:(NSString*)firstName
                            lastName:(NSString*)lastName
                               phone:(NSString*)phone
                              avatar:(NSString*)avatarLink
                          socialLink:(NSString*)socialLink
                    socialIdentifier:(NSString*)socialId
                         accessToken:(NSString*)accessToken
                              userId:(NSString*)userId;

-(void)userInfo;
-(void)userOrders;
//manage cookies
- (void)deleteCookieFromLocalStorage;
- (void)saveCookies;
- (void)restoreCookies;
- (void)deleteCookies;

@end
