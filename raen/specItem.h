//
//  specItem.h
//  raenapp
//
//  Created by Alexey Ivanov on 27.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"

@protocol specItem @end
@interface specItem : JSONModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *db1cId;
@property (nonatomic, strong) NSString *modelId;
@property (nonatomic, strong) NSString <Optional> *colorId;
@property (nonatomic, strong) NSString <Optional> *price;

@property (nonatomic, strong) NSString <Optional> *param1;
@property (nonatomic, strong) NSString <Optional> *param2;
@property (nonatomic, strong) NSString <Optional> *param3;
@property (nonatomic, strong) NSString <Optional> *param4;
@property (nonatomic, strong) NSString <Optional> *param5;
@property (nonatomic, strong) NSString <Optional> *sklad;
@property (nonatomic, strong) NSString <Optional> *shop;
@property (nonatomic, strong) NSString <Optional> *piter;
@property (nonatomic, strong) NSString <Optional> *color;
@end
