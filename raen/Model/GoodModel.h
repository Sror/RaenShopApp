//
//  GoodModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 22.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol GoodModel @end
@interface GoodModel : JSONModel
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *catId;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,getter = isAvailable) BOOL available;
@property (nonatomic,getter = isSale) BOOL sale;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *priceNew;
@property (nonatomic,strong) NSString <Optional>*weight;
@property (nonatomic,strong) NSString <Optional>*desc;
@property (nonatomic,strong) NSString <Optional>*video;
@property (nonatomic,strong) NSString <Optional>*imageLink;
@property (nonatomic,strong) NSString <Optional>*seo;
@property (nonatomic,strong) NSString <Optional>*param1;
@property (nonatomic,strong) NSString <Optional>*param2;
@property (nonatomic,strong) NSString <Optional>*param3;
@property (nonatomic,strong) NSString <Optional>*param4;
@property (nonatomic,strong) NSString <Optional>*param5;
@property (nonatomic,strong) NSString <Optional>*brand;

@end
