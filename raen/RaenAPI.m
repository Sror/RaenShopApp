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


#import "RaenAPI.h"
#import "JSONModelLib.h"
#import "GoodModel.h"
#import "CategoryModel.h"

NSString *RaenAPIGotBikes = @"RaenAPIGotBikes";
NSString *RaenAPIGotCategories = @"RaenAPIGotCategories";
NSString *RaenAPIGotGuards = @"RaenAPIGotGuards";

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
                                      NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                      for (NSHTTPCookie* cookie in [cookieJar cookies]) {
                                          if ([cookie.domain isEqualToString:@"raenshop.ru"]&&[cookie.name
                                                                                               isEqualToString:@"ci_session"]) {
                                              NSLog(@"current cookie value %@", cookie.value);
                                          }
                                      }
                                     // NSLog(@"Got JSON from web: %@", json);
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          return;
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
                                      
                                      NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                      for (NSHTTPCookie* cookie in [cookieJar cookies]) {
                                          if ([cookie.domain isEqualToString:@"raenshop.ru"]&&[cookie.name
                                               isEqualToString:@"ci_session"]) {
                                              NSLog(@"current cookie value %@", cookie.value);
                                          }
                                      }
                                      
                                      //NSLog(@"Got JSON from web: %@", json);
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          return;
                                      }
                                      _categories = [CategoryModel arrayOfModelsFromDictionaries:[[json reverseObjectEnumerator] allObjects]];
                                      if (_categories){
                                          NSLog(@"_categories loaded!");
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIGotCategories object:self];
                                          
                                      }
                                      
                                  }];

}
-(void)updateGuards{
   
    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetGuard
                                  completion:^(id json, JSONModelError *err) {
                                      NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
                                      for (NSHTTPCookie* cookie in [cookieJar cookies]) {
                                          if ([cookie.domain isEqualToString:@"raenshop.ru"]&&[cookie.name
                                                                                              isEqualToString:@"ci_session"]) {
                                              NSLog(@"current cookie value %@", cookie.value);
                                          }
                                      }
                                      //got JSON back
                                      //NSLog(@"Got JSON from web: %@", json);
                                      if (err) {
                                          NSLog(@"err %@",err.localizedDescription);
                                          return;
                                      }
                                      _guards = [GoodModel arrayOfModelsFromDictionaries:json[@"goods"]];
                                      if (_guards){
                                          NSLog(@"_guards loaded!");
                                          self.guards = _guards;
                                          [[NSNotificationCenter defaultCenter] postNotificationName:RaenAPIGotGuards object:self];
                                          
                                      }
                                      
                                  }];
}
@end
