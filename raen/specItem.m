//
//  specItem.m
//  raenapp
//
//  Created by Alexey Ivanov on 27.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "specItem.h"

@implementation specItem
+(JSONKeyMapper *)keyMapper{
    return  [[JSONKeyMapper alloc] initWithDictionary:@{
                                                        @"db1c_id":@"db1cId",
                                                        @"color_id":@"colorId",
                                                        @"model_id":@"modelId"
                                                        }];
    
}

@end
