//
//  CartViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 12.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "CartViewController.h"
#import "HUD.h"
#import "AppDelegate.h"
#import "CartItemModel.h"


@interface CartViewController ()

@end

@implementation CartViewController

-(void)gotCartItems{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RaenAPIGorCurrentCartItems object:self.raenAPI];
    [HUD hideUIBlockingIndicator];
    [HUD showTimedAlertWithTitle:@"Success!" text:Nil withTimeout:1];
    NSLog(@"succesfuly gotCartItems %@",self.raenAPI.currentCartItems);
    [self.tableView reloadData];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [self.raenAPI getCartItems];
    [HUD showUIBlockingIndicatorWithText:@"Loading..."];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotCartItems) name:RaenAPIGorCurrentCartItems object:self.raenAPI];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.raenAPI = [[AppDelegate instance] raenAPI];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSUInteger count = self.raenAPI.currentCartItems.count;
   
    if (count>0) {
        return count;
    } else{
        return 1;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tb cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CartCell";
    
    NSUInteger itemsCount = self.raenAPI.currentCartItems.count;
    if (itemsCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tb dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"У вас еще нет товаров в корзине…";
		return cell;
    }
    UITableViewCell *cell = [tb dequeueReusableCellWithIdentifier:cellIdentifier];
    if (itemsCount>0) {
        CartItemModel *itemInCart = self.raenAPI.currentCartItems[indexPath.row];
        cell.textLabel.text = itemInCart.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Кол-во: %@",itemInCart.qty];
    }
    return cell;
}
@end
