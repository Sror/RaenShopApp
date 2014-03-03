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

#import "CartItemModel.h"
#import "GoodModel.h"
#import "CategoryModel.h"
#import "NewsCategoryModel.h"

#define kRaenApiGetGuard @"http://raenshop.ru/api/catalog/goods_list/cat_id/81/" //get all guard items
#define kRaenApiGetCategories @"http://raenshop.ru/api/catalog/categories" //get all categories
#define kRaenApiGetCart @"http://raenshop.ru/api/catalog/cart/" //get items in cart
#define kRaenApiGetItemCard @"http://raenshop.ru/api/catalog/goods/id/"
#define kRaenApiGetSubcategoryItems @"http://raenshop.ru/api/catalog/goods_list/cat_id/"
#define kRaenApiSendToCartItem @"http://raenshop.ru/api/catalog/to_cart/"
#define kRaenApiGetNews @"http://raenshop.ru/api/news/categories/"

@implementation RaenAPICommunicator

-(void)getNews{
    NSLog(@"getting news from %@",kRaenApiGetNews);
    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetNews completion:^(id json, JSONModelError *err) {
        if (err) {
            NSLog(@"err %@",err.localizedDescription);
            [self.delegate fetchingFailedWithError:err];
        }
        NSArray *news = [NewsCategoryModel arrayOfModelsFromDictionaries:json];
        if (news) {
            [self.delegate didReceiveNews:news];
        }else{
            NSLog(@"----something went wrong with init JSONModel----");
        }
    }];
}

-(void)getSubcategoryWithId:(NSString*)subcategoryId{
   
    NSString *urlStr =[kRaenApiGetSubcategoryItems stringByAppendingString:subcategoryId];
    NSLog(@"getting items in subcategory from %@",urlStr);
    [JSONHTTPClient getJSONFromURLWithString:urlStr completion:^(id json, JSONModelError *err) {
        if (err) {
            NSLog(@"err %@",err.localizedDescription);
            [self.delegate fetchingFailedWithError:err];
            
        }
        NSArray *subcategoryItems = [GoodModel arrayOfModelsFromDictionaries:json[@"goods"]];
        if (subcategoryItems) {
            [self.delegate didReceiveSubcategoryItems:subcategoryItems];
        }else{
            NSLog(@"----something went wrong with init JSONModel----");
        }
    }];
}

-(void)getItemCardWithId:(NSString*)itemId{
   
    NSString *urlStr = [kRaenApiGetItemCard stringByAppendingString:itemId];
    NSLog(@"getting item json data from %@",urlStr);
    [JSONHTTPClient getJSONFromURLWithString:urlStr
                                  completion:^(id json, JSONModelError *err) {
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

- (void)getAllCategories{
    NSLog(@"getting all categories");
    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetCategories
                                  completion:^(id json, JSONModelError *err) {

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
#pragma mark -
#pragma mark CART methods
-(void)getItemsFromCart{
    NSLog(@"getting items from cart");
    //TODO add cookie !
    [self restoreCookies];
    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetCart
                                  completion:^(id json, JSONModelError *err) {
                                      if (err) {
                                          NSLog(@"err! %@",err.localizedDescription);
                                          [self.delegate fetchingFailedWithError:err];
                                      }
                                      NSLog(@"json from cart %@",json);
                                      NSArray *cartItems =[CartItemModel arrayOfModelsFromDictionaries:json];
                                      if (cartItems) {
                                          [self.delegate didReceiveCartItems:cartItems];
                                      }else{
                                          NSLog(@"----something went wrong with init JSONModel----");
                                      }
                                      
                                  }];
   
}

#warning fix add item to cart
-(void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session =[NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:kRaenApiSendToCartItem];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [self restoreCookies];
    [request setHTTPMethod:@"POST"];
    SpecItem *specItem = item.specItems[index];
    NSString *price =item.priceNew.length >2 ? item.priceNew : item.price;
    NSString *params =[NSString stringWithFormat:@"name=%@,%@&id=%@&price=%@&qty=1",item.title,specItem.color,specItem.db1cId,price];
    
    NSLog(@"parameters %@",params);
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
       // NSLog(@"Response:%@ %@\n", response, error);
        if(error == nil)
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            [self.delegate didAddItemToCartWithResponse:json];
        }else{
#warning TODO notification when had error to add item to cart
            
            NSLog(@"---error to add item to cart------");
        }
    }];
    [dataTask resume];
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
            NSLog(@"standartUserDefaults setValue %@ forKey:%@",cookieProperties,cookie.name);
            [[NSUserDefaults standardUserDefaults] setValue:cookieProperties forKey:cookie.name];
        }
    }
    NSLog(@"%@",cookieArray);
    [[NSUserDefaults standardUserDefaults] setValue:cookieArray forKey:@"cookieArray"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
-(void)restoreCookies{
    NSLog(@"restore cookies");
    NSMutableArray* cookieDictionary = [[NSUserDefaults standardUserDefaults] valueForKey:@"cookieArray"];
    NSLog(@"cookie dictionary found is %@",cookieDictionary);
    
    for (int i=0; i < cookieDictionary.count; i++)
    {
        NSLog(@"cookie found is %@",[cookieDictionary objectAtIndex:i]);
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
