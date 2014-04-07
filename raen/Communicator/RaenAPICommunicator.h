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
extern NSString* kRAENAPISocialAuthDict;
extern NSString* kRAENAPISocialAccessToken;
extern NSString* kRAENAPISocialIdentifier;


@class RaenAPICommunicator;

@interface RaenAPICommunicator : NSObject 
@property (weak, nonatomic) id<RaenAPICommunicatorDelegate> delegate;
@property (nonatomic,strong) NSString *raenAPIAccessToken;



- (void)getNewsByPage:(NSInteger)page;
- (void)getAllCategories;
- (void)getParamsOfCategoryWithId:(NSString*)categoryId;
- (void)getSubcategoryWithId:(NSString*)subcategoryId withParameters:(NSDictionary*)parameters;
- (void)getItemCardWithId:(NSString*)itemId;
- (void)getSliderItems;
- (void)getSaleOfDay;
//cart
- (void)getItemsFromCart;
- (void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty;
- (void)changeCartItemQTY:(NSString*)qty byRowID:(NSString*)rowid;
//- (void)deleteItemFromCartWithID:(NSString*)id;
//authorization via socials
- (void)authAPIVia:(NSString*)socialName
withuserIdentifier:(NSString*)userId
       accessToken:(NSString*)token
optionalParameters:(NSDictionary*)optionalParametersDictionary;

- (void)registrationNewUserWithEmail:(NSString*)email
                           firstName:(NSString*)firstName
                            lastName:(NSString*)lastName
                               phone:(NSString*)phone
                              avatar:(NSString*)avatarLink
                          socialLink:(NSString*)socialLink
                    socialIdentifier:(NSString*)socialId
                         accessToken:(NSString*)accessToken
                              userId:(NSString*)userId;
//Auth data in userdefailts
- (void)saveAuthDataToDefaultsWith:(NSString*)socialId accessToken:(NSString*)accessToken;
- (void)removeAuthDataFromDefaults;


//manage cookies
- (void)deleteCookieFromLocalStorage;
- (void)saveCookies;
- (void)restoreCookies;
- (void)deleteCookies;

@end
