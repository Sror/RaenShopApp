//
//  SpecItem.m
//  raenapp
//
//  Created by Alexey Ivanov on 12.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "SpecItem.h"

@implementation SpecItem
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"db1c_id":@"db1cId",
                                                       @"new_price":@"priceNew"
                                                       }];
}
@end
