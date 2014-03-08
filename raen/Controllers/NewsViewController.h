//
//  NewsViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewsViewController : UIViewController <UITableViewDataSource,UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (strong,nonatomic) UIRefreshControl* refreshControl;
@end
