//
//  NewsModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 20.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol NewsModel @end
@interface NewsModel : JSONModel
@property (nonatomic,strong) NSString <Optional> *title;
@property (nonatomic,strong) NSString <Optional> *date;
@property (nonatomic,strong) NSString <Optional> *link;
@property (nonatomic,strong) NSString <Optional> *image;
@end
