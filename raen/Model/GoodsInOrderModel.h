//
//  GoodsInOrderModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 21.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol GoodsInOrderModel @end

@interface GoodsInOrderModel : JSONModel
@property (nonatomic,strong) NSString<Optional>* id;
@property (nonatomic,strong) NSString<Optional>* orderId;
@property (nonatomic,strong) NSString<Optional>* title;
@property (nonatomic,strong) NSString<Optional>* price;
@property (nonatomic,strong) NSString<Optional>* qty;
@property (nonatomic,strong) NSString<Optional>* image;
@property (nonatomic,strong) NSString<Optional> *params;

@end
