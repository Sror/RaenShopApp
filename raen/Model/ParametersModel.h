//
//  ParametersModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 26.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol ParametersModel @end
@interface ParametersModel : JSONModel
@property (nonatomic,strong) NSString * title;
@property (nonatomic,strong) NSString * name;
@property (nonatomic,strong) NSArray  * values;

@end
