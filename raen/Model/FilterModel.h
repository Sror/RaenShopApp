//
//  FilterModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 26.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
#import "ColorModel.h"
#import "BrandModel.h"
#import "ParametersModel.h"

@interface FilterModel : JSONModel
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString <Optional> *parent;
@property (nonatomic,strong) NSString <Optional> *seo;
@property (nonatomic,strong) NSString <Optional> *title;
@property (nonatomic,strong) NSString <Optional> *param1;
@property (nonatomic,strong) NSString <Optional> *param2;
@property (nonatomic,strong) NSString <Optional> *param3;
@property (nonatomic,strong) NSString <Optional> *param4;
@property (nonatomic,strong) NSString <Optional> *param5;
@property (nonatomic,assign) BOOL visible;
@property (nonatomic,strong) NSString <Optional> *image;
@property (nonatomic,strong) NSArray <Optional,ColorModel> *colors;
@property (nonatomic,strong) NSArray <Optional,BrandModel> *brands;
@property (nonatomic,strong) NSArray <Optional,ParametersModel> *parameters;
@end
