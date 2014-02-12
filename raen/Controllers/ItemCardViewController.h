//
//  ItemViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RaenAPI.h"
#import "AppDelegate.h"

@interface ItemCardViewController : UIViewController <UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate>
//@property (nonatomic,strong) NSString *itemID;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) RaenAPI *raenAPI;

-(void)showItem;

@end
