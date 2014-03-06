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
#import "CartItemParamsModel.h"
#import "RaenAPICommunicator.h"
#import "CartCell.h"
#import "UIImageView+WebCache.h"

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
    [self.tableView setHidden:YES];
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
    [self.tableView setHidden:NO];
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
-(void)didRemoveItemFromCartWithResponse:(NSDictionary *)response{
    NSLog(@"didRemoveItemFromCartWithResponse %@",response);
    [_communicator saveCookies];
    [HUD hideUIBlockingIndicator];
    [self.tableView reloadData];
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
    CartCell *cell = [tb dequeueReusableCellWithIdentifier:cellIdentifier];
    NSUInteger itemsCount = _items.count;
    if (itemsCount == 0 && indexPath.row == 0)
	{
        cell.titleLabel.text = @"У вас еще нет товаров в корзине…";
        cell.textView.text = nil;
        cell.priceLabel.text = nil;
		return cell;
    }
    if (itemsCount>0) {
        CartItemModel *itemInCart = _items[indexPath.row];
        cell.titleLabel.text = itemInCart.name;
        [cell.spinner startAnimating];
        [cell.itemImageView setImageWithURL:[NSURL URLWithString:itemInCart.image]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                      [cell.spinner stopAnimating];
                                  }];
        cell.priceLabel.text = [NSString stringWithFormat:@"%@ руб.",itemInCart.price];
        cell.textView.text = itemInCart.params;
        
       // cell.textView.text = [self allParamsToString:itemInCart.params];
        //cell.detailTextLabel.text = [NSString stringWithFormat:@"Кол-во: %@",itemInCart.qty];
        
    }
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete item at Index %d",indexPath.row);
        [HUD showUIBlockingIndicator];
        CartItemModel *cartItem = _items[indexPath.row];
        [_communicator removeItemFromCartWithID:cartItem.id];
    }
}

#pragma mark - Helpers
-(NSString*)allParamsToString:(NSArray*)params{
    NSString *fullstring =@"";
    for (CartItemParamsModel *param in params) {
        if (param.title) {
            fullstring = [fullstring stringByAppendingString:[NSString stringWithFormat:@"\n%@",param.title]];
        }
    }
    return fullstring;
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
