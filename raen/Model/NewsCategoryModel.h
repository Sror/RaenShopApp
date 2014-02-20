//
//  NewsCategoryModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 20.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
#import "NewsModel.h"

@interface NewsCategoryModel : JSONModel
@property (nonatomic,strong) NSString <Optional> *title;
@property (nonatomic,strong) NSString <Optional> *type;
@property (nonatomic,strong) NSString <Optional> *total;
@property (nonatomic,strong) NSArray <NewsModel,Optional> *news;
@end
