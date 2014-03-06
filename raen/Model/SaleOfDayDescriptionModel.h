//
//  SaleOfDayDescriptionModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol SaleOfDayDescriptionModel @end
@interface SaleOfDayDescriptionModel : JSONModel
@property (nonatomic,strong) NSString <Optional> *text;
@property (nonatomic,strong) NSString <Optional> *id;
@end
