//
//  PickParameterViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 26.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ColorModel.h"
#import "BrandModel.h"
#import "ParametersModel.h"

@class PickParameterViewController;

@protocol PickParameterViewControllerDelegate<NSObject>
-(void)didSelectColor:(ColorModel*)color;
-(void)didSelectBrand:(BrandModel*)brand;
-(void)didSelectValues:(NSString*)values ofParameter:(ParametersModel*)parameter;
@end


@interface PickParameterViewController : UITableViewController
@property (nonatomic, weak) id <PickParameterViewControllerDelegate> delegate;

@property (nonatomic,strong) NSArray *colors;
@property (nonatomic,strong) NSArray *brands;
@property (nonatomic,strong) ParametersModel *parameter;

@end
