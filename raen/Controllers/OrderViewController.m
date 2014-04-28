//
//  OrderViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 21.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "OrderViewController.h"

#import "UIImageView+WebCache.h"
#import "CartCell.h"
@interface OrderViewController ()

@end

@implementation OrderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setHidden:self.goodies ? NO:YES];
    GoodsInOrderModel *firstItem=self.goodies[0];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Заказ №%@",firstItem.orderId]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.goodies.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    OrderItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderItemCell"];
//    GoodsInOrderModel *currentItem = self.goodies[indexPath.row];
//    cell.priceLabel.text = [NSString stringWithFormat:@"%@ руб.",currentItem.price];
//    cell.titleLabel.text = currentItem.title;
//    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
//    [cell.imageview setImageWithURL:[NSURL URLWithString:currentItem.image]
//                          completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
//    }];
//
    CartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CartCell"];
    GoodsInOrderModel* currentItem =self.goodies[indexPath.row];
    cell.titleLabel.text = currentItem.title;
    cell.priceLabel.text = [NSString stringWithFormat:@"%@ руб.",currentItem.price];
    cell.textView.text = currentItem.params;
      [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [cell.itemImageView setImageWithURL:[NSURL URLWithString:currentItem.image]
                              completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    [cell.qtyTextField setUserInteractionEnabled:NO];
    cell.qtyTextField.text = currentItem.qty;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
@end
