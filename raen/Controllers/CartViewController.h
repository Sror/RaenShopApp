//
//  CartViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 12.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaenAPICommunicatorDelegate.h"



@interface CartViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,RaenAPICommunicatorDelegate,UITextFieldDelegate>


@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UILabel *subTotalLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkOutButton;
@property (weak, nonatomic) IBOutlet UITabBarItem *tabBarItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)checkOutButtonPressed:(id)sender;
-(NSString*)itemsCount;

@end
