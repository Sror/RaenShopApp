//
//  SaleOfDayModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "SaleOfDayModel.h"

@implementation SaleOfDayModel
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"description":@"descriptions"
                                                       
                                                       }];
}
@end
