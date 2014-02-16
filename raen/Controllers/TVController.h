//
//  TVController.h
//  raenapp
//
//  Created by Alexey Ivanov on 16.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TVController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>

@property (strong,nonatomic) IBOutlet UILabel *mainLabel;
@property (nonatomic,strong) IBOutlet UITableView *tableView;



@end
