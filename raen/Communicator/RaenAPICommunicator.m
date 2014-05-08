//
//  RaenAPICommunicator.m
//  raenapp
//
//  Created by Alexey Ivanov on 14.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "RaenAPICommunicator.h"
#import "RaenAPICommunicatorDelegate.h"

#import "Socializer.h"

#import "JSONModelLib.h"
#import "NewsModel.h"
#import "CartItemModel.h"
#import "SubcategoryModel.h"
#import "FilterModel.h"

#import "CategoryModel.h"
#import "SliderModel.h"
#import "SaleOfDayModel.h"
#import "UserInfoModel.h"
#import "OrderModel.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


int RaenAPIdefaulSubcategoryItemsCountPerPage = 30;
int RaenAPIdefaultNewsItemsCountPerPage = 10;

#warning add/remove hash below
#define kRaenAPIAuthValue @"Basic ="

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
#define kRaenAPIAuthViaEmail @"http://raenshop.ru/api/auth/login"
#define kRaenApiAuthViaSocial @"http://raenshop.ru/api/auth/social"
#define kRaenAPIUserInfo @"http://raenshop.ru/api/auth/user/token/"
#define kRaenAPIUserOrders @"http://raenshop.ru/api/auth/user_orders/token/"
#define kraenAPICheckout @"http://raenshop.ru/api/catalog/checkout/"

@implementation RaenAPICommunicator

#pragma mark - get News
-(void)getNewsByPage:(NSInteger)page{
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
        if (parameters[@"sort"]!=nil) {
            urlStr = [urlStr stringByAppendingString:[NSString stringWithFormat:@"/sort/%@", parameters[@"sort"]]];
        }
        
        NSArray *paramNames = @[@"param1",@"param2",@"param3",@"param4",@"param5"];
        for (NSString *paramName in paramNames)
        {
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
                                          id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                          [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Подкатегория товара"
                                                                                                action:@"Получил список товаров в подкатегории"
                                                                                                 label:[NSString stringWithFormat:@"%@",parameters]
                                                                                                 value:nil] build]];
                                      }else{
                                          NSLog(@"----something went wrong with init JSONModel----");
                                          
                                          id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                          [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Подкатегория товара"
                                                                                                action:@"Ошибка при получении списока товаров в подкатегории"
                                                                                                 label:[NSString stringWithFormat:@"%@",err]
                                                                                                 value:nil] build]];
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
                                      id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                      [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Карточка товара"
                                                                                            action:@"Ошибка при Получении карточки товара"
                                                                                             label:[NSString stringWithFormat:@"%@",err]
                                                                                             value:nil] build]];
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
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *urlStr= kRaenApiGetCart;
    NSString* token = [[Socializer sharedManager] raenAPIToken];
    if (token) {
        urlStr =   [urlStr stringByAppendingString:[NSString stringWithFormat:@"token/%@",token]];
    }
    NSLog(@"getting items from cart by URL %@",urlStr);
    [JSONHTTPClient JSONFromURLWithString:urlStr
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
                                   
                                      NSArray *cartItems =[CartItemModel arrayOfModelsFromDictionaries:json];
                                      if (cartItems) {
                                          [self.delegate didReceiveCartItems:cartItems];
                                          id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                          [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Корзина"
                                                                                                action:@"Получил список товаров в корзине"
                                                                                                 label:[NSString stringWithFormat:@"В корзине %i товаров",cartItems.count]
                                                                                                 value:nil] build]];
                                      }else{
                                          id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                          [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Корзина"
                                                                                                action:@"Ошибка получении списка товаров"
                                                                                                 label:[NSString stringWithFormat:@"%@",err]
                                                                                                 value:nil] build]];
                                          NSLog(@"----something went wrong with init JSONModel----");
                                      }
                                  }];
   
}
-(void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty{
    [self restoreCookies];
    SpecItem *specItem = item.specItems[index];
    //NSLog(@"adding item in cart  %@",item);
    NSString *price =item.priceNew.length >2 ? item.priceNew : item.price;
    NSString *bodyParams =[NSString stringWithFormat:@"name=%@ %@, %@&id=%@&price=%@&qty=1&token=%@",item.brand,item.title,specItem.color,specItem.db1cId,price,[[Socializer sharedManager] raenAPIToken]];
    NSLog(@"parameters %@",bodyParams);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiSendToCartItem
                                   method:@"POST"
                                   params:nil
                             orBodyString:bodyParams
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   NSLog(@"did add item to cart json response :%@",json);
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   if(!err )
                                   {
                                       if ([json isKindOfClass:[NSDictionary class]]) {
                                       [self.delegate didAddItemToCartWithResponse:json];
                                       id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                       [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Корзина"
                                                                                             action:@"Добавил в корзину"
                                                                                              label:bodyParams
                                                                                              value:nil] build]];
                                       }
                                   }else{
                                       id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                       [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Корзина"
                                                                                             action:@"Ошибка при добавлении в корзину"
                                                                                              label:[NSString stringWithFormat:@"%@",err]
                                                                                              value:nil] build]];
                                       NSLog(@"---error to add item to cart------");
                                   }

                               }];
    
   
   
    

}
-(void)changeCartItemQTY:(NSString*)qty byRowID:(NSString*)rowid{
    [self restoreCookies];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString* token = [[Socializer sharedManager] raenAPIToken];
    //token  = token ? token : @"0";
    NSDictionary *params = @{@"rowid":rowid,
                             @"qty":qty,
                             @"token":token ? token : @""
                             };
    NSLog(@"changing cart item QTY with params %@",params);
    [JSONHTTPClient JSONFromURLWithString:kRaenApiUpdateCart
                                   method:@"POST"
                                   params:params
                             orBodyString:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [self saveCookies];
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   if ([json isKindOfClass:[NSDictionary class]]) {
                                       [self.delegate didChangeCartItemQTYWithResponse:json];
                                       
                                       id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                       [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Корзина"
                                                                                             action:@"Изменил кол. товаров в корзине"
                                                                                              label:[NSString stringWithFormat:@"%@",params]
                                                                                              value:nil] build]];
                                   }
                                   if (err!=nil) {
                                       
                                       NSLog(@"error to change qty item from cart %@",err.localizedDescription);
                                   }
                               }];
    
    
}
#pragma mark - Checkout
- (void)checkoutFastWithFirstName:(NSString*)firstName andPhone:(NSString*)phone{
    [self restoreCookies];
    NSString *token = [[Socializer sharedManager] raenAPIToken];
    NSMutableDictionary *tmpDict = [[NSMutableDictionary alloc]
                                    initWithDictionary:@{@"firstname": firstName,
                                                         @"phone":phone,
                                                         @"delivery":@"fast"}];
   //add token if exist
    if (token) {
        [tmpDict addEntriesFromDictionary:@{@"token":token}];
    }
    NSLog(@"checking out fast with parameters %@",tmpDict);
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    [JSONHTTPClient JSONFromURLWithString:kraenAPICheckout
                                   method:@"POST"
                                   params:tmpDict
                               orBodyData:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
                                   [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   [self saveCookies];
                                   
                                   if ([json isKindOfClass:[NSDictionary class]]) {
                                       [self.delegate didCheckoutWithResponse:json];
                                   }
                                   if (err) {
                                       
                                       id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                       [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Оформление заказа"
                                                                                             action:@"Ошибка при оформлении заказа"
                                                                                              label:[NSString stringWithFormat:@"%@",err]
                                                                                              value:nil] build]];
                                       NSLog(@"---ERROR to check out : %@ ---",err);
                                   }
     
    }];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Оформление заказа"
                                                          action:@"Отправил запрос на оформление заказа"
                                                           label:[NSString stringWithFormat:@"%@",tmpDict]
                                                           value:nil] build]];
   
    
}
#pragma mark - Authorization via email
-(void)authViaEmail:(NSString*)email andPassword:(NSString*)password{
    [self restoreCookies];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenAPIAuthViaEmail
                                   method:@"POST"
                                   params:@{@"email":email,@"password":password}
                               orBodyData:nil
                                  headers:@{@"Authorization":kRaenAPIAuthValue}
                               completion:^(id json, JSONModelError *err) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                   [self saveCookies];
                                   if ([json isKindOfClass:[NSDictionary class]]) {
                                       if (err || json[@"error"]) {
                                           [self.delegate didFailuerAPIAuthorizationWithResponse:json];
                                           
                                           id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                           [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Авторизация"
                                                                                                 action:@"Ошибка входа ч/з email/pass"
                                                                                                  label:json[@"error"]
                                                                                                  value:nil] build]];
                                       }
                                       if (json[@"success"]) {
                                           [Socializer sharedManager].raenAPIToken = json[@"token"];
                                           [[Socializer sharedManager] saveAuthUserDataToDefaults];
                                           
                                           [self.delegate didSuccessAPIAuthorizedWithResponse:json];
                                           
                                           id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
                                           [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Авторизация"
                                                                                                 action:@"Успешный Вход ч/з email/pass"
                                                                                                  label:email
                                                                                                  value:nil] build]];
                                       }
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [JSONHTTPClient JSONFromURLWithString:kRaenApiAuthViaSocial
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
          
           NSString *errorMsg = jsonDict[@"error"];
           if (errorMsg) {
               id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
               [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Авторизация"
                                                                     action:@"Ошибка входа"
                                                                      label:[NSString stringWithFormat:@"%@ через %@ c ошибкой %@",[Socializer sharedManager].socialUsername,[Socializer sharedManager].socialIdentificator,jsonDict]
                                                                      value:nil] build]];
           }
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
               [Socializer sharedManager].raenAPIToken = jsonDict[@"token"];
               [[Socializer sharedManager] saveAuthUserDataToDefaults];
               
               [self.delegate didSuccessAPIAuthorizedWithResponse:jsonDict];
               
               id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
               [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Авторизация"
                                                                     action:@"Успешный вход"
                                                                      label:[NSString stringWithFormat:@"%@ через %@",[Socializer sharedManager].socialUsername,[Socializer sharedManager].socialIdentificator]
                                                                      value:nil] build]];

           }
           
       }
    }];
                                  
    
}
- (void)signInNewUserWithEmail:(NSString*)email
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
    NSDictionary *optionalValues = @{@"email"       : email ?       email : @"",
                                     @"first_name"  : firstName ?   firstName : @"",
                                     @"last_name"   : lastName ?    lastName : @"",
                                     @"phone"       : phone ?       phone : @"",
                                     @"avatar"      : avatarLink ?  avatarLink : @"",
                                     @"link"        : socialLink ?  socialLink : @""
                                     };

    NSLog(@"sign in new user with options %@",optionalValues);
    
    if (![socialId isEqualToString:@""] && ![accessToken isEqualToString:@""] && ![socialId isEqualToString:@""]) {
        [self authAPIVia:socialId withuserIdentifier:userId accessToken:accessToken optionalParameters:optionalValues];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Авторизация"
                                                              action:@"Регистрация нового пользователя"
                                                               label:[NSString stringWithFormat:@"%@ через %@ c параметрами %@",[Socializer sharedManager].socialUsername,[Socializer sharedManager].socialIdentificator,optionalValues]
                                                               value:nil] build]];
    }else{
        NSLog(@"----NO socialID/AccessToken/SocialID! Can't sign in new user!-----");
    }    
}

#pragma mark - User Info 
-(void)userInfo{
    [self restoreCookies];
    NSString *token =[Socializer sharedManager].raenAPIToken;
    if (token) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString *fullUrl = [kRaenAPIUserInfo stringByAppendingString:token];
        NSLog(@"getting user info from %@",fullUrl);
        [JSONHTTPClient JSONFromURLWithString:fullUrl
                                       method:@"GET"
                                       params:nil
                                   orBodyData:nil
                                      headers:@{@"Authorization":kRaenAPIAuthValue}
                                   completion:^(id json, JSONModelError *err) {
                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                       [self saveCookies];
                                       
                                       if (json[@"error"]) {
                                           NSLog(@"---ERROR: %@---",json[@"error"]);
                                           [[Socializer sharedManager]logOutFromCurrentSocial];
                                       }else{
                                           if ([json isKindOfClass:[NSDictionary class]]) {
                                               NSError *jsonInitializationError;
                                               UserInfoModel *userInfo = [[UserInfoModel alloc] initWithDictionary:json error:&jsonInitializationError];
                                               if (jsonInitializationError) {
                                                   NSLog(@"jsonInitializationError %@",jsonInitializationError);
                                               }else{
                                                   [self.delegate didReceiveUserInfo:userInfo];
                                               }
                                               
                                           }
                                       }
        }];
    }else{
        NSLog(@"---Can't get userInfo cause user NOT authorized! (token = nil) ----");
    }
}
#pragma mark - User Orders
-(void)userOrders{
    [self restoreCookies];
    NSString *token =[Socializer sharedManager].raenAPIToken;
    if (token) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        NSString* fullUrl = [kRaenAPIUserOrders stringByAppendingString:token];
        NSLog(@"getting user orders from %@",fullUrl);
        [JSONHTTPClient JSONFromURLWithString:fullUrl
                                       method:@"GET"
                                       params:nil
                                   orBodyData:nil
                                      headers:@{@"Authorization":kRaenAPIAuthValue}
                                   completion:^(id json, JSONModelError *err) {
                                       [self saveCookies];
                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                       if ([json isKindOfClass:[NSDictionary class]]) {
                                           if (json[@"error"]) {
                                               NSLog(@"---ERORR: %@-----",json[@"error"]);
                                           }
                                       }else{
                                           if ([json isKindOfClass:[NSArray class]]) {
                                               NSArray *orders = [OrderModel arrayOfModelsFromDictionaries:json error:&err];
                                               [self.delegate didReceiveUserOrders:orders];
                                           }
                                       }
    }];
    }else{
        NSLog(@"---Can't get user orders cause user NOT authorized! (token = nil) ----");
    }
}



#pragma mark - Cookie manager methods
-(void)deleteCookieFromLocalStorage{
    NSLog(@"deleting cookies from local storage");
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"cookieArray"];
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
