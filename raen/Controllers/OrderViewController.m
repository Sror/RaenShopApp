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

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface OrderViewController ()

@end

@implementation OrderViewController

-(void)viewDidAppear:(BOOL)animated{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Order Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setHidden:self.goodies ? NO:YES];
    GoodsInOrderModel *firstItem=self.goodies[0];
    [self.navigationItem setTitle:[NSString stringWithFormat:@"Заказ №%@",firstItem.orderId]];
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
