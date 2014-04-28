//
//  OrderViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 21.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GoodsInOrderModel.h"

@interface OrderViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property NSArray* goodies;

@end
