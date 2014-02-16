//
//  CartItemModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 06.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"

@interface CartItemModel : JSONModel
@property (nonatomic,strong) NSString *rowid;
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *qty;
@property (nonatomic,strong) NSString *price;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *subtotal;
@property (nonatomic,strong) NSString *params;

@end
