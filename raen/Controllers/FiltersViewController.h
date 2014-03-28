//
//  FiltersViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 25.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickParameterViewController.h"

@class FiltersViewController;
@protocol FiltersViewControllerDelegate <NSObject>

-(void)didSelectFilter:(NSDictionary*)filterParameters;

@end
@interface FiltersViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,PickParameterViewControllerDelegate>

@property (nonatomic, weak) id <FiltersViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSString *subcategoryID;


@end
