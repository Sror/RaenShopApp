//
//  CartItemParamsModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 05.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol CartItemParamsModel @end
@interface CartItemParamsModel : JSONModel
@property (nonatomic,strong) NSString <Optional>*title;
@property (nonatomic,strong) NSString <Optional>*value;
@end
