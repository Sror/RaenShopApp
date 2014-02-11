//
//  ItemModel.h
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "JSONModel.h"
#import "specItem.h"
#import "ImageModel.h"

@interface ItemModel : JSONModel
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *catId;
@property (nonatomic, getter = isAvailable) BOOL available;
@property (nonatomic, strong) NSString <Optional>*review;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *price;
@property (nonatomic,strong) NSString <Optional>*priceNew;
@property (nonatomic, strong) NSString <Optional> *weight;
@property (nonatomic, strong) NSString <Optional> *desc;
@property (nonatomic, strong) NSString <Optional> *brand;
@property (nonatomic, strong) NSString <Optional> *brandId;
@property (nonatomic, strong) NSString <Optional> *video;
@property (nonatomic, strong) NSString <Optional> *imageMainLink;
@property (nonatomic, strong) NSString <Optional> *imageBigLink;
@property (nonatomic, strong) NSArray <specItem> *specItems;
@property (nonatomic, strong) NSArray <ImageModel,Optional> *images;
@end
