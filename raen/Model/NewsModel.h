//
//  NewsModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 20.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@interface NewsModel : JSONModel

@property (nonatomic,strong) NSString <Optional> *title;
@property (nonatomic,strong) NSString <Optional> *date;
@property (nonatomic,strong) NSString <Optional> *link;
@property (nonatomic,strong) NSString <Optional> *image;
@property (nonatomic,strong) NSString <Optional> *text;
@property (nonatomic,strong) NSString <Optional> *type;

@end
