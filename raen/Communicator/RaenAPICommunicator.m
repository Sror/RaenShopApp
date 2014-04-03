//
//  RaenAPICommunicator.m
//  raenapp
//
//  Created by Alexey Ivanov on 14.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "RaenAPICommunicator.h"
#import "RaenAPICommunicatorDelegate.h"
#import "JSONModelLib.h"
#import "NewsModel.h"
#import "CartItemModel.h"
#import "SubcategoryModel.h"
#import "FilterModel.h"

#import "CategoryModel.h"
#import "SliderModel.h"
#import "SaleOfDayModel.h"

int RaenAPIdefaulSubcategoryItemsCountPerPage = 30;
int RaenAPIdefaultNewsItemsCountPerPage = 10;
NSString* kRAENAPISocialAuthDict = @"RAEN_API_SOCIAL_AUTH_DICT";
NSString* kRAENAPISocialAccessToken =@"RAEN_API_SOCIAL_ACCESS_TOKEN";
NSString* kRAENAPISocialIdentifier = @"RAEN_API_SOCIAL_IDENTIFIER";

#warning add/remove hash below
#define kRaenAPIAuthValue @"Basic =="

#define kRaenApiGetGuard @"http://raenshop.ru/api/catalog/goods_list/cat_id/81/" //get all guard items
#define kRaenApiGetParamsOfCategory @"http://raenshop.ru/api/catalog/category/id/"
#define kRaenApiGetCategories @"http://raenshop.ru/api/catalog/categories" //get all categories
#define kRaenApiGetCart @"http://raenshop.ru/api/catalog/cart/" //get items from cart
#define kRaenApiGetItemCard @"http://raenshop.ru/api/catalog/goods/id/"
#define kRaenApiGetSubcategoryItems @"http://raenshop.ru/api/catalog/goods_list/cat_id/"
#define kRaenApiSendToCartItem @"http://raenshop.ru/api/catalog/to_cart/"
#define kRaenApiGetNews @"http://raenshop.ru/api/news/list/"
#define kRaenApiGetNewsByPage @"http://raenshop.ru/api/news/list/page/"
#define kRaenApiGetSliderItems @"http://raenshop.ru/api/news/slider/"
#define kRaenApiGetSaleOfDay @"http://raenshop.ru/api/news/sale_of_day/"
#define kRaenApiUpdateCart @"http://raenshop.ru/api/catalog/update_cart/"
#define kRaenApiAuth @"http://raenshop.ru/api/auth/social"

@implementation RaenAPICommunicator

#pragma mark - get News
-(void)getNewsByPage:(NSInteger)page{
    NSLog(@"getting news by page %d",page);
    [self restoreCookies];
    NSString *fullUrlString = [kRaenApiGetNewsByPage stringByAppendingString:[NSString stringWithFormat:@"%ld",(long)page]];
    NSLog(@"fullURLString %@",fullUrlString);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:fullUrlString
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err)
    {
        [self saveCookies];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (err) {
            NSLog(@"err %@",err.localizedDescription);
            [self.delegate fetchingFailedWithError:err];
        }
        NSArray *news = [NewsModel arrayOfModelsFromDictionaries:json];
        if (news) {
            [self.delegate didReceiveNews:news];
        }else{
            NSLog(@"----something went wrong with init JSONModel----");
        }
    }];
}
#pragma mark - get parameters of category
-(void)getParamsOfCategoryWithId:(NSString*)categoryId{
    NSString *url = [kRaenApiGetParamsOfCategory stringByAppendingString:categoryId];
    [self restoreCookies];
    NSLog(@"get params from %@",url);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:url
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   if (err) {
                                       NSLog(@"err %@",err.localizedDescription);
                                       [self.delegate fetchingFailedWithError:err];
                                   }
                                   FilterModel *filter = [[FilterModel alloc] initWithDictionary:json error:nil];
                                   if (filter) {
                                       [self.delegate didReceiveFilter:filter];
                                   }else{
                                       NSLog(@"----something went wrong with init JSONModel----");
                                   }
                               }];
    
}
#pragma mark - get Subcategory With id
-(void)getSubcategoryWithId:(NSString*)subcategoryId withParameters:(NSDictionary*)parameters {
    [self restoreCookies];
    NSString *urlStr =[kRaenApiGetSubcategoryItems stringByAppendingString:subcategoryId];
    NSLog(@"getting items in subcategory from %@ with parameters %@",urlStr,parameters);
    if (parameters) {
        if (parameters[@"page"]!=nil) {
            urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/page/%@",parameters[@"page"]]];
        }
        if (parameters[@"color"]!=nil) {
            urlStr = [ urlStr stringByAppendingString:[NSString stringWithFormat:@"/color/%@",parameters[@"color"]]];
        }
        if (parameters[@"brand"]!=nil) {
            urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/brand/%@",parameters[@"brand"]]];
        }
        NSArray *paramNames = @[@"param1",@"param2",@"param3",@"param4",@"param5"];
        for (NSString *paramName in paramNames) {
            if ([parameters objectForKey:paramName]!=nil) {
                urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/%@/%@",paramName,parameters[paramName]]];
            }
        }
    }
    
    NSLog(@"fullUrlString %@",urlStr);
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:[urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                    [self saveCookies];
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          [self.delegate fetchingFailedWithError:err];
                                      }
                                      SubcategoryModel *subcategoryModel = [[SubcategoryModel alloc] initWithDictionary:json error:nil];
                                      // NSArray *subcategoryItems = [GoodModel arrayOfModelsFromDictionaries:json[@"goods"]];
                                      if (subcategoryModel) {
                                          //[self.delegate didReceiveSubcategoryItems:subcategoryItems];
                                          [self.delegate didReceiveSubcategory:subcategoryModel];
                                      }else{
                                          NSLog(@"----something went wrong with init JSONModel----");
                                      }
                                  }];

}
#pragma mark -get Item Card With id
-(void)getItemCardWithId:(NSString*)itemId{
   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self restoreCookies];
    NSString *urlStr = [kRaenApiGetItemCard stringByAppendingString:itemId];
    NSLog(@"getting item json data from %@",urlStr);
    [JSONHTTPClient JSONFromURLWithString:urlStr
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  if (err) {
                                      NSLog(@"err %@",err.localizedDescription);
                                      [self.delegate fetchingFailedWithError:err];
                                  }
                                  ItemModel *item = [[ItemModel alloc] initWithDictionary:json error:nil];
                                  if (item ) {
                                      [self.delegate didReceiveItemCard:item];
                                  }else{
                                      NSLog(@"----something went wrong with init JSONModel----");
                                  }
                              }];
}
#pragma mark - get All Categories
- (void)getAllCategories{
    NSLog(@"getting all categories");
    [self restoreCookies];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiGetCategories
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                  if (err) {
                                      NSLog(@"err %@",err.localizedDescription);
                                      [self.delegate fetchingFailedWithError:err];
                                  }
                                  NSArray *categories = [CategoryModel arrayOfModelsFromDictionaries:json];
                                  if (categories){
                                      [self.delegate didReceiveAllCategories:categories];
                                  }else{
                                      NSLog(@"----something went wrong with init JSONModel----");
                                  }
                              }];

}


#pragma mark - Slider items
- (void)getSliderItems{
    NSLog(@"getting slider items");
    [self restoreCookies];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiGetSliderItems
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   if (err) {
                                       NSLog(@"err! %@",err.localizedDescription);
                                       [self.delegate fetchingFailedWithError:err];
                                   }
                                   NSArray *sliderItems =[SliderModel arrayOfModelsFromDictionaries:json];
                                   if (sliderItems) {
                                       [self.delegate didReceiveSliderItems:sliderItems];
                                   }else{
                                       NSLog(@"----something went wrong with init JSONModel----");
                                   }
   }];
    
}
#pragma mark - SaleOfDay
- (void)getSaleOfDay{
    NSLog(@"get sale of day");
    [self restoreCookies];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiGetSaleOfDay
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                    if (err) {
                                        NSLog(@"eror to get sale of day %@",err.localizedDescription);
                                        [self.delegate fetchingFailedWithError:err];
                                    }else{
                                        SaleOfDayModel *saleOfdayModel =[[SaleOfDayModel alloc]initWithDictionary:json error:nil ];
                                        if (saleOfdayModel) {
                                            [self.delegate didReceiveSaleOfDay:saleOfdayModel];
                                        }else{
                                            NSLog(@"----something went wrong with init JSONModel----");
                                            
                                        }
                                    }
    }];
    
}
#pragma mark -
#pragma mark CART methods
-(void)getItemsFromCart{
    
    [self restoreCookies];
    NSLog(@"getting items from cart");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiGetCart
                                   method:@"GET"
                                   params:nil
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                      if (err) {
                                          NSLog(@"err! %@",err.localizedDescription);
                                          [self.delegate fetchingFailedWithError:err];
                                      }
                                      NSLog(@"get items from cart json %@",json);
                                      NSArray *cartItems =[CartItemModel arrayOfModelsFromDictionaries:json];
                                      if (cartItems) {
                                          [self.delegate didReceiveCartItems:cartItems];
                                      }else{
                                          NSLog(@"----something went wrong with init JSONModel----");
                                      }
                                  }];
   
}
-(void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty{
    [self restoreCookies];
    SpecItem *specItem = item.specItems[index];
    NSLog(@"adding item in cart  %@",item);
    NSString *price =item.priceNew.length >2 ? item.priceNew : item.price;
    NSString *bodyParams =[NSString stringWithFormat:@"name=%@ %@,%@&id=%@&price=%@&qty=1",item.brand,item.title,specItem.color,specItem.db1cId,price];
    NSLog(@"parameters %@",bodyParams);
    [self restoreCookies];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiSendToCartItem
                                   method:@"POST"
                                   params:nil
                             orBodyString:bodyParams
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   if(!err )
                                   {
                                       if ([json isKindOfClass:[NSDictionary class]]) {
                                       [self.delegate didAddItemToCartWithResponse:json];
                                       }
                                   }else{
#warning TODO notification when had error to add item to cart
                                    
                                       NSLog(@"---error to add item to cart------");
                                   }

                               }];
}
-(void)deleteItemFromCartWithID:(NSString*)rowid{
    NSLog(@"delete items with rowid %@",rowid);
    [self restoreCookies];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self restoreCookies];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiUpdateCart
                                   method:@"POST"
                                   params:@{@"rowid":rowid,@"qty":@"0"}
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   if ([json isKindOfClass:[NSDictionary class]]) {
                                       [self.delegate didRemoveItemFromCartWithResponse:json];
                                   }
                                   if (err!=nil) {
#warning add delegate method with error
                                       NSLog(@"error to remove object from cart %@",err.localizedDescription);
                                   }
                               }];
}

#pragma mark - authorization via social networks
-(void)authAPIVia:(NSString *)socialName withuserIdentifier:(NSString*)userId
      accessToken:(NSString*)token
optionalParameters:(NSDictionary*)optionalParametersDictionary
{
    [self restoreCookies];
    
    NSMutableDictionary *requestParameters = [NSMutableDictionary dictionary];
        if (socialName!=nil && userId!=nil && token !=nil) {
            [requestParameters addEntriesFromDictionary:@{@"social":socialName,
                                  @"identifier":userId,
                                  @"token":token
                                  }];
    }
    if (optionalParametersDictionary) {
        [requestParameters addEntriesFromDictionary:optionalParametersDictionary];
    }
    
    NSLog(@"authorization with parameters %@",requestParameters);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];;
    [JSONHTTPClient JSONFromURLWithString:kRaenApiAuth
                                   method:@"POST"
                                   params:requestParameters
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err)
    {
       [self saveCookies];
       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
       if ([json isKindOfClass:[NSDictionary class]]) {
           NSDictionary *jsonDict = json;
           NSLog(@"json RAEN API authorization %@",jsonDict);
           NSString *errorMsg = jsonDict[@"error"];
           //if email required
           if ([errorMsg isEqualToString:@"Email is required"]) {
               
               [self.delegate didEmailRequest];
               
           }else if ([errorMsg isEqualToString:@"User with this email already exists"]){
               [self.delegate didExistEmail];
               
           }else if (errorMsg)
           {
               [self.delegate didFailuerAPIAuthorizationWithResponse:jsonDict];
           }
           if (jsonDict[@"success"]) {
               _raenAPIAccessToken = jsonDict[@"token"];
               [self saveAuthDataToDefaultsWith:socialName accessToken:_raenAPIAccessToken];
               NSLog(@"Did save AccessToken to UserDefaults? %@",[[NSUserDefaults standardUserDefaults]
                                                                  objectForKey:kRAENAPISocialAuthDict] ? @"YES":@"NO");
               [self.delegate didSuccessAPIAuthorizedWithResponse:jsonDict];
           }
           
       }else {
#warning TODO bad response from API server!
       }
    }];
                                  
    
}
- (void)registrationNewUserWithEmail:(NSString*)email
                      firstName:(NSString*)firstName
                       lastName:(NSString*)lastName
                          phone:(NSString*)phone
                         avatar:(NSString*)avatarLink
                          socialLink:(NSString*)socialLink
                    socialIdentifier:(NSString*)socialId
                         accessToken:(NSString*)accessToken
                              userId:(NSString*)userId
{
    [self restoreCookies];
    NSMutableDictionary *optionalValues = [NSMutableDictionary dictionary];
    if (email) {
        [optionalValues addEntriesFromDictionary:@{@"email":email}];
    }
    if (firstName) {
        [optionalValues addEntriesFromDictionary:@{@"first_name":firstName}];
    }
    if (lastName) {
        [optionalValues addEntriesFromDictionary:@{@"last_name":lastName}];
    }
    if (phone) {
        [optionalValues addEntriesFromDictionary:@{@"phone":phone}];
    }
    if (avatarLink) {
        [optionalValues addEntriesFromDictionary:@{@"avatar":avatarLink}];
    }
    if (socialLink) {
        [optionalValues addEntriesFromDictionary:@{@"link":socialLink}];
    }
    
    NSLog(@"registrationNewUserWith %@",optionalValues);
    if (socialId!=nil && accessToken!=nil && socialId !=nil) {
        [self authAPIVia:socialId withuserIdentifier:userId accessToken:accessToken optionalParameters:optionalValues];
    }
}
#pragma mark - Save AccessToken
- (void)saveAuthDataToDefaultsWith:(NSString*)socialId accessToken:(NSString*)accessToken {
    NSDictionary *authDict = @{kRAENAPISocialIdentifier:socialId,kRAENAPISocialAccessToken:accessToken};
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:authDict forKey:kRAENAPISocialAuthDict];
    [defaults synchronize];
    NSLog(@"Auth dict in userdefaults %@",[defaults objectForKey:kRAENAPISocialAuthDict]);
}
-(void)removeAuthDataFromDefaults{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kRAENAPISocialAuthDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"did remove Auth data from userDefaults? %@",![[NSUserDefaults standardUserDefaults] objectForKey:kRAENAPISocialAuthDict] ? @"YES":@"NO");
}

#pragma mark - Cookie manager methods
-(void)deleteCookieFromLocalStorage{
    NSLog(@"deleting cookies from local storage");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookieArray"];
    NSLog(@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"cookieArray"]);
    [[NSUserDefaults standardUserDefaults]synchronize];
}
-(void)saveCookies{
    NSLog(@"saving cookies");
    NSMutableArray *cookieArray = [[NSMutableArray alloc] init];
    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
        if ([cookie.domain isEqualToString:@"raenshop.ru"]&&[cookie.name isEqualToString:@"ci_session"]) {
            [cookieArray addObject:cookie.name];
            NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
            [cookieProperties setObject:cookie.name forKey:NSHTTPCookieName];
            [cookieProperties setObject:cookie.value forKey:NSHTTPCookieValue];
            [cookieProperties setObject:cookie.domain forKey:NSHTTPCookieDomain];
            [cookieProperties setObject:cookie.path forKey:NSHTTPCookiePath];
            [cookieProperties setObject:[NSNumber numberWithInt:cookie.version] forKey:NSHTTPCookieVersion];
#warning time interval?
            [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
            [[NSUserDefaults standardUserDefaults] setValue:cookieProperties forKey:cookie.name];
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:cookieArray forKey:@"cookieArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)restoreCookies{
    NSLog(@"restore cookies");
    NSMutableArray* cookieDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:@"cookieArray"];
    for (int i=0; i < cookieDictionary.count; i++)
    {
        NSMutableDictionary* cookieDictionary1 = [[NSUserDefaults standardUserDefaults] valueForKey:cookieDictionary[i]];
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieDictionary1];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

-(void)deleteCookies
{
    NSLog(@"deleting allcookies");
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [storage cookies])
    {
        [storage deleteCookie:cookie];
    }
}
@end
