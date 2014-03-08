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
    if (![response objectForKey:@"success"]) {
        NSLog(@"error to remove item");
        UIAlertView *alert  =[[UIAlertView alloc] initWithTitle:@"Error" message:response[@"error"] delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
        [HUD hideUIBlockingIndicator];
    }else{
        [_communicator saveCookies];
        [self.tabBarItem setBadgeValue:[self itemsCount]];
        [HUD hideUIBlockingIndicator];
        [_communicator getItemsFromCart];
    }
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _items.count;
}
-(UITableViewCell *)tableView:(UITableView *)tb cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CartCell";
    CartCell *cell = [tb dequeueReusableCellWithIdentifier:cellIdentifier];
    CartItemModel *itemInCart = _items[indexPath.row];
    cell.titleLabel.text = itemInCart.name;
    [cell.spinner startAnimating];
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:itemInCart.image]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                  [cell.spinner stopAnimating];
                              }];
    cell.priceLabel.text = [NSString stringWithFormat:@"%@ руб.",itemInCart.price];
    cell.textView.text = itemInCart.params;

    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Удалить";
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_items.count==0) {
        return @"Нет товаров в корзине";
    }
    
    return nil;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"delete item at Index %d",indexPath.row);
        //[tableView  deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[tableView reloadData];
        [HUD showUIBlockingIndicator];
        CartItemModel *cartItem = _items[indexPath.row];
        [_communicator deleteItemFromCartWithID:cartItem.rowid];
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
