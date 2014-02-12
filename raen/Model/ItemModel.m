//
//  ItemModel.m
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ItemModel.h"

@implementation ItemModel

+(JSONKeyMapper *)keyMapper{
    return  [[JSONKeyMapper alloc] initWithDictionary:@{
                                    @"cat_id":@"catId",
                                    @"brand_id":@"brandId",
                                    @"new_price":@"priceNew",
                                    //@"spec_items":@"specItems",
                                    @"image_main":@"imagesMainLink",
                                    @"image_big":@"imageBigLink",
                                    @"dop_images":@"images"
                                                        }];
}

@end
