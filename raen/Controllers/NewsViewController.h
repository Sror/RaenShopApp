//
//  NewsViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 20.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "TVController.h"

@interface NewsViewController : TVController <UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate>
@property (strong,nonatomic) IBOutlet UILabel *mainLabel;
@property (nonatomic,strong) IBOutlet UITableView *tableView;



@end
