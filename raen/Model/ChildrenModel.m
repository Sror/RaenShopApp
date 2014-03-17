//
//  ChildrenModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 23.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ChildrenModel.h"

@implementation ChildrenModel

+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"image":@"imageLink"
                                                       }];
}

@end
