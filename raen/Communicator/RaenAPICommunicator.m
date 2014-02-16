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
#import "ItemModel.h"
#import "CategoryModel.h"


#define kRaenApiGetGuard @"http://raenshop.ru/api/catalog/goods_list/cat_id/81/" //get all guard items
#define kRaenApiGetCategories @"http://raenshop.ru/api/catalog/categories" //get all categories
#define kRaenApiGetCart @"http://raenshop.ru/api/catalog/cart/" //get items in cart
#define kRaenApiGetItemCard @"http://raenshop.ru/api/catalog/goods/id/"
#define kRaenApiGetSubcategoryItems @"http://raenshop.ru/api/catalog/goods_list/cat_id/"
#define kRaenApiSendToCartItem @"http://raenshop.ru/api/catalog/to_cart/"
@implementation RaenAPICommunicator

-(void)getItemsFromCart{
    NSLog(@"getting items from cart");
    //TODO add cookie !
    [JSONHTTPClient getJSONFromURLWithString:kRaenApiGetCart
                                  completion:^(id json, JSONModelError *err) {
                                      if (err) {
                                          NSLog(@"err! %@",err.localizedDescription);
                                          [self.delegate fetchingFailedWithError:err];
                                      }
                                      NSArray *cartItems =[CartItemModel arrayOfModelsFromDictionaries:json];
                                      if (cartItems) {
                                          [self.delegate didReceiveCartItems:cartItems];
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
#warning fix add item to cart
-(void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty{
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session =[NSURLSession sessionWithConfiguration:configuration];
    NSURL *url = [NSURL URLWithString:kRaenApiSendToCartItem];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    SpecItem *specItem = item.specItems[index];
    NSString *price =item.priceNew.length >2 ? item.priceNew : item.price;
    NSString *params =[NSString stringWithFormat:@"name=%@,%@&id=%@&price=%@&qty=1",item.title,specItem.color,specItem.db1cId,price];
    
    NSLog(@"parameters %@",params);
    [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSLog(@"Response:%@ %@\n", response, error);
        if(error == nil)
        {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            //NSLog(@"JSONData %@",json);
            /*
             NSString * text = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
             NSLog(@"Data = %@",text);
             */
        }
        
    }];
    
    [dataTask resume];
    
}
@end
