//
//  SpecItem.h
//  raenapp
//
//  Created by Alexey Ivanov on 12.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol SpecItem @end
@interface SpecItem : JSONModel
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *db1cId;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString <Optional>*priceNew;

@end
