//
//  OrderModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 21.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "OrderModel.h"

@implementation OrderModel
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"order_id":@"orderId",
                                                       @"day_delivery":@"deliveryDay",
                                                       @"goods":@"goodsInOrder"
                                                       }];
}

@end
