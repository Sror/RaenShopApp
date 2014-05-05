//
//  LoginViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 18.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ProfileViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView* tableView;
@property NSArray* orders;

@end
