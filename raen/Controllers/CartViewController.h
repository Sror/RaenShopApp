//
//  CartViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 12.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaenAPI.h"

@interface CartViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) RaenAPI *raenAPI;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
