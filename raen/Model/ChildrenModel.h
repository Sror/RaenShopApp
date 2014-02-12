//
//  ChildrenModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 23.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol ChildrenModel @end
@interface ChildrenModel : JSONModel
@property (nonatomic,strong) NSString *id;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *imageLink;
@end
