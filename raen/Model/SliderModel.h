//
//  SliderModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 03.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"

@interface SliderModel : JSONModel
@property (nonatomic,strong) NSString <Optional>*action;
@property (nonatomic,strong) NSString <Optional>*image;
@property (nonatomic,strong) NSString <Optional>*link;
@property (nonatomic,strong) NSString <Optional>*id;

@end
