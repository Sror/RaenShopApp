//
//  ImageModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 28.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
@protocol ImageModel @end
@interface ImageModel : JSONModel
@property (nonatomic,strong) NSString *thumb;
@property (nonatomic,strong) NSString *big;

@end
