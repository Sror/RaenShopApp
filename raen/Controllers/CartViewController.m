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
#import "RaenAPICommunicator.h"


@interface CartViewController ()<RaenAPICommunicatorDelegate>
{
    RaenAPICommunicator *_communicator;
    NSArray *_items;

}
@end

@implementation CartViewController
@synthesize tabBarItem;

-(void)viewWillAppear:(BOOL)animated{
    
    [self.subView setHidden:YES];
    [HUD showUIBlockingIndicatorWithText:Nil];
    [_communicator getItemsFromCart];
}
-(NSString*)itemsCount{
    int itemsCount = 0;
    for (int i=0; i<_items.count; i++) {
        CartItemModel *currentItem = _items[i];
        itemsCount = itemsCount + [currentItem.qty intValue];
    }
    return [NSString stringWithFormat:@"%i",itemsCount];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    //[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:[self itemsCount]]];
    
    //User Interface
    [self.subView.layer setCornerRadius:3.0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RaenAPICommunicationDelegate
-(void)didReceiveCartItems:(NSArray *)items{
    NSLog(@"didReceiveCartItems %@",items);
    [HUD hideUIBlockingIndicator];
    _items = items;
    
    [self.tabBarItem setBadgeValue:[self itemsCount]];
    [self.tableView reloadData];
    [self.subTotalLabel setText:[self subtotal]];
    [self.subView setHidden:NO];
}
-(void)fetchingFailedWithError:(JSONModelError *)error {
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_items.count>0) {
        return _items.count;
    } else{
        return 1;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tb cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CartCell";
    UITableViewCell *cell = [tb dequeueReusableCellWithIdentifier:cellIdentifier];
    NSUInteger itemsCount = _items.count;
    if (itemsCount == 0 && indexPath.row == 0)
	{
        cell.textLabel.text = @"";
		cell.detailTextLabel.text = @"У вас еще нет товаров в корзине…";
		return cell;
    }
    
    if (itemsCount>0) {
        CartItemModel *itemInCart = _items[indexPath.row];
        cell.textLabel.text = itemInCart.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Кол-во: %@",itemInCart.qty];
        
    }
    return cell;
}
-(NSString*)subtotal{
    NSInteger total=0;
    for (CartItemModel *cartItem in _items) {
        total = total + [cartItem.subtotal intValue];
    };
    return [NSString stringWithFormat:@"Итого: %i руб.",total];
}
- (IBAction)checkOutButtonPressed:(id)sender {
    NSLog(@"checkOutButtonPressed");
}
@end
