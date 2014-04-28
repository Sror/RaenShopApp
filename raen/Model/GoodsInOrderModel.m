//
//  GoodsInOrderModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 21.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "GoodsInOrderModel.h"

@implementation GoodsInOrderModel
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"order_id":@"orderId",
                                                       @"params_str":@"params"
                                                       }];
}
@end
