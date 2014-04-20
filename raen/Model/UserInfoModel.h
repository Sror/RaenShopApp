//
//  UserInfoModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 18.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"

@interface UserInfoModel : JSONModel
@property (nonatomic,strong) NSString <Optional>* username;
@property (nonatomic,strong) NSString <Optional>* email;
@property (nonatomic,strong) NSString <Optional>* created;
@property (nonatomic,strong) NSString <Optional>* phone;
@property (nonatomic,strong) NSString <Optional>* avatar;

@end
