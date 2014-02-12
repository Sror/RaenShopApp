//
//  CategoryModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 23.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "CategoryModel.h"

@implementation CategoryModel
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"children": @"childrens",
                                                       @"image":@"imageLink"
                                                       }];
}
@end
