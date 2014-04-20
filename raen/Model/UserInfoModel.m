//
//  UserInfoModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 18.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "UserInfoModel.h"

@implementation UserInfoModel
+(JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"created_on":@"created",
                                                       @"last_login":@"lastLogin"
                                                       }];
}
@end
