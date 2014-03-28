//
//  ParametersModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 26.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ParametersModel.h"

@implementation ParametersModel
+(JSONKeyMapper *)keyMapper{
    return  [[JSONKeyMapper alloc] initWithDictionary:@{
                                                        @"arr":@"values"
                                                        }];
}
@end
