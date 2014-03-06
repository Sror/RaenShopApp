//
//  SaleOfDayModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
#import "SaleOfDayDescriptionModel.h"

@interface SaleOfDayModel : JSONModel
@property (nonatomic,assign) NSString <Optional> *complete;
@property (nonatomic,strong) NSString <Optional> *image;
@property (nonatomic,strong) NSArray <SaleOfDayDescriptionModel,Optional> *descriptions;
@end
