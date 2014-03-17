//
//  CategoryModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 23.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
#import "ChildrenModel.h"

@protocol CategoryModel @end
@interface CategoryModel : JSONModel
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString <Optional> *param1;
@property (nonatomic,strong) NSArray <ChildrenModel,Optional> *childrens;
@property (nonatomic,strong) NSString *imageLink;
@end
