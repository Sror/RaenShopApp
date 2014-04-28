//
//  OrderModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 21.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
#import "GoodsInOrderModel.h"

@interface OrderModel : JSONModel
@property (nonatomic,strong) NSString <Optional>* id;
@property (nonatomic,strong) NSString <Optional>* uid;
@property (nonatomic,strong) NSString <Optional>* email;
@property (nonatomic,strong) NSString <Optional>* lastname;
@property (nonatomic,strong) NSString <Optional>* firstname;
@property (nonatomic,strong) NSString <Optional>* otch;
@property (nonatomic,strong) NSString <Optional>* phone;
@property (nonatomic,strong) NSString <Optional>* status;
@property (nonatomic,strong) NSString <Optional>* comment;
@property (nonatomic,strong) NSString <Optional>* tracking;
@property (nonatomic,strong) NSString <Optional>* deliveryDay;
@property (nonatomic,strong) NSArray <Optional,GoodsInOrderModel>* goodsInOrder;

@end
