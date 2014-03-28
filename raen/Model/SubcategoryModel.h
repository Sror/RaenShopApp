//
//  SubcategoryModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 17.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
#import "GoodModel.h"

@interface SubcategoryModel : JSONModel
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, strong) NSArray <GoodModel,Optional> *goods;
@end
