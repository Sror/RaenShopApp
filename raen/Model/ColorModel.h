//
//  ColorModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 26.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"


@protocol ColorModel @end
@interface ColorModel : JSONModel
@property (nonatomic,strong) NSString  *id;
@property (nonatomic,strong) NSString  *name;
@end
