//
//  RaenAPI.m
//  raenapp
//
//  Created by Alexey Ivanov on 10.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//
#define kRaenApiGetBikesURL @"http://raenshop.ru/api/catalog/goods_list/cat_id/26/"//get all complete bikes
#define kRaenApiGetGuard @"http://raenshop.ru/api/catalog/goods_list/cat_id/81/" //get all guard items
#define kRaenApiGetCategories @"http://raenshop.ru/api/catalog/categories" //get all categories
#define kRaenApiGetCart @"http://raenshop.ru/api/catalog/cart/" //get items in cart
#define kRaenApiGetItemCard @"http://raenshop.ru/api/catalog/goods/id/"
#define kRaenApiGetSubcategoryItems @"http://raenshop.ru/api/catalog/goods_list/cat_id/"

#import "RaenAPI.h"
#import "JSONModelLib.h"
#import "GoodModel.h"
#import "CategoryModel.h"

NSString *RaenAPIFailedGetData = @"RaenAPIFailedGetData";

NSString *RaenAPIGotBikes = @"RaenAPIGotBikes";
NSString *RaenAPIGotCategories = @"RaenAPIGotCategories";
NSString *RaenAPIGotGuards = @"RaenAPIGotGuards";
NSString *RaenAPIGotCurrentItem = @"RaenAPIGotCurrentItem";
NSString *RaenAPIGotCurrentSubcategoryItems = @"RaenAPIGotCurrentSubcategoryItems";
@implementation RaenAPI
@synthesize ready;

#pragma mark - Singleton
+(RaenAPI *)sharedInstance{
    static dispatch_once_t once;
    static RaenAPI *sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance =[[self alloc]init];
    });
    return sharedInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        ready = NO;
        self.bikes = nil;
        self.categories = nil;
        self.guards = nil;
    }
    return self;
}

-(NSURLSession*)session{
    if (!_session) {
        NSURLSessionConfiguration *sessionConf = [NSURLSessionConfiguration defaultSessionConfiguration];
        [sessionConf setHTTPAdditionalHeaders:@{@"Accept": @"application/json"}];
        
        _session = [NSURLSession sessionWithConfiguration:sessionConf];
    }
    return _session;
}

-(void)updateBikes{
    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetBikesURL
                                  completion:^(id json, JSONModelError *err) {
                                      [self logCookie];
                                     // NSLog(@"Got JSON from web: %@", json);
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          return;
                                          //TODO FAILURE NOTIFICATION
                                      }
                                      _bikes = [GoodModel arrayOfModelsFromDictionaries:
                                                json[@"goods"]];
                                      if (_bikes){
                                          NSLog(@"Bikes loaded!");
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIGotBikes object:self];
                                          
                                      }
                                      
                                  }];
}

-(void)updateCategories{

    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetCategories
                                  completion:^(id json, JSONModelError *err) {
                                      [self logCookie];
                                      //NSLog(@"Got JSON from web: %@", json);
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIFailedGetData object:self];
                                      }
                                      _categories = [CategoryModel arrayOfModelsFromDictionaries:[[json reverseObjectEnumerator] allObjects]];
                                      if (_categories){
                                          NSLog(@"_categories loaded!");
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIGotCategories object:self];
                                      }
                                  }];

}
//helper
-(void)logCookie{
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie* cookie in [cookieJar cookies]) {
        if ([cookie.domain isEqualToString:@"raenshop.ru"]&&[cookie.name isEqualToString:@"ci_session"]) {
            NSLog(@"current cookie value %@", cookie.value);
        }
    }

}
-(void)updateGuards{
    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetGuard
                                  completion:^(id json, JSONModelError *err) {
                                      [self logCookie];
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIFailedGetData object:self];
                                      }
                                      _guards = [GoodModel arrayOfModelsFromDictionaries:json[@"goods"]];
                                      if (_guards){
                                          NSLog(@"_guards loaded!");
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIGotGuards object:self];
                                          
                                      }
                                      
                                  }];
}
-(void)getItemCardWithId:(NSString*)itemId{
    _currentItem = nil;
    NSString *urlStr = [kRaenApiGetItemCard stringByAppendingString:itemId];
    NSLog(@"getting item json data from %@",urlStr);
    [JSONHTTPClient getJSONFromURLWithString:urlStr
                                  completion:^(id json, JSONModelError *err) {
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIFailedGetData object:err];
                                      }
                                      _currentItem = [[ItemModel alloc] initWithDictionary:json error:nil];
                                      if (_currentItem) {
                                          NSLog(@"_currentItem ready");
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIGotCurrentItem object:self];
                                          
                                      }
                                  }];
    
}

-(void)getSubcategoryWithId:(NSString*)subcategoryId{
    _currentSubcategoryItems = nil;
    NSString *urlStr =[kRaenApiGetSubcategoryItems stringByAppendingString:subcategoryId];
    NSLog(@"getting items in subcategory from %@",urlStr);
    [JSONHTTPClient getJSONFromURLWithString:urlStr completion:^(id json, JSONModelError *err) {
        if (err) {
            NSLog(@"err %@",err.localizedDescription);
           [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIFailedGetData object:self];
            
        }
        _currentSubcategoryItems = [GoodModel arrayOfModelsFromDictionaries:json[@"goods"]];
        if (_currentSubcategoryItems) {
            NSLog(@"__currentSubcategoryItems ready");
            [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIGotCurrentSubcategoryItems object:self];
        }
    }];

}
@end
