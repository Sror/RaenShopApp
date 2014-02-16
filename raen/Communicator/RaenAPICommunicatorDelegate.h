//
//  RaenAPICommunicatorDelegate.h
//  raenapp
//
//  Created by Alexey Ivanov on 14.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModelError.h"


@protocol RaenAPICommunicatorDelegate <NSObject>
@optional
- (void)didReceiveCartItems:(NSArray *)items;

- (void)didReceiveSubcategoryItems:(NSArray *)items;
- (void)didReceiveItemCard:(id)itemCard;
- (void)didReceiveAllCategories:(NSArray *)array;
@required
- (void)fetchingFailedWithError:(JSONModelError *)error;
@end
