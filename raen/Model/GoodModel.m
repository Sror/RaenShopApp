//
//  GoodModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 22.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "GoodModel.h"

@implementation GoodModel
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"image":@"imageLink",
                                                       @"new_price":@"priceNew",
                                                       @"cat_id":@"catId",
                                                       @"bramd_id":@"brandId"
                                                       }];
}
@end
