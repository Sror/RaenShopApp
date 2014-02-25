//
//  CartViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 12.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaenAPICommunicatorDelegate.h"

@interface CartViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,RaenAPICommunicatorDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UILabel *subTotalLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkOutButton;
- (IBAction)checkOutButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItem;
-(NSString*)itemsCount;
@end
