//
//  RaenAPI.h
//  raenapp
//
//  Created by Alexey Ivanov on 10.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemModel.h"

extern  NSString *RaenAPIFailedGetData;
extern  NSString *RaenAPIGotBikes;
extern  NSString *RaenAPIGotCategories;
extern  NSString *RaenAPIGotGuards;
extern  NSString *RaenAPIGotCurrentItem;
extern  NSString *RaenAPIGotCurrentSubcategoryItems;
extern  NSString *RaenAPIGorCurrentCartItems;

@interface RaenAPI : NSObject <NSURLSessionDelegate>

@property (nonatomic,readonly,getter = isReady) BOOL ready;
@property (nonatomic,strong) NSArray *bikes;
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) NSArray *guards;
@property (nonatomic,strong) ItemModel *currentItem;
@property (nonatomic,strong) NSArray *currentSubcategoryItems;
@property (nonatomic,strong) NSArray *currentCartItems;
/*
@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDataTask *dataTask;
*/
+(RaenAPI*)sharedInstance;

-(void)updateBikes;
-(void)updateCategories;
-(void)updateGuards;

-(void)getItemCardWithId:(NSString*)itemId;
-(void)getSubcategoryWithId:(NSString*)subcategoryId;
-(void)getCartItems;
-(void)addItemToCart:(ItemModel*)item withSpecItemAtIndex:(NSInteger)index andQty:(NSUInteger)qty;
@end
