//
//  GridItemsVC.m
//  raenapp
//
//  Created by Alexey Ivanov on 30.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "GridItemsVC.h"
#import "ItemCell.h"
#import "HUD.h"
#import "GoodModel.h"
#import "UIImageView+WebCache.h"
#import "ItemCardViewController.h"

#define kRaenApiItemsLink @"http://raenshop.ru/api/catalog/goods_list/cat_id/"

@interface GridItemsVC (){
    //NSArray *_items;
}

@end

@implementation GridItemsVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.raenAPI = [[AppDelegate instance] raenAPI];
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
    JSONModelError *err;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedGetJsonWithJSONError:) name:RaenAPIFailedGetData object:err];
}
-(void)failedGetJsonWithJSONError:(JSONModelError*)err{
    
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:err.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
    
}
-(void)viewWillDisappear:(BOOL)animated{
    //self.raenAPI.currentSubcategoryItems = nil;
}
-(void)showItems{
    NSLog(@"showItems");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RaenAPIGotCurrentSubcategoryItems object:self.raenAPI];
    [HUD hideUIBlockingIndicator];
    [HUD showTimedAlertWithTitle:@"Succes" text:@"to get item" withTimeout:1];
    
    [self.collectionView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource
#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.raenAPI.currentSubcategoryItems.count;
};

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CollectionViewCellIdentifier = @"itemCell";
    ItemCell *itemCell = (ItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    GoodModel *item = self.raenAPI.currentSubcategoryItems[indexPath.row];
    itemCell.titleLabel.text = item.title;
    [itemCell.activityIndicator startAnimating];
    if (![item.priceNew isEqualToString:@"0"]) {
        itemCell.priceNewLabel.text = [NSString stringWithFormat:@"%@ руб.",item.priceNew];
        itemCell.priceLabel.text = [NSString stringWithFormat:@"Было %@ руб.",item.price];
    }else{
        itemCell.priceNewLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1.0];
        itemCell.priceNewLabel.text = [NSString stringWithFormat:@"%@ руб.",item.price];
        [itemCell.priceLabel setHidden:YES];
    }
    [itemCell.imageView setImageWithURL:[NSURL URLWithString:item.imageLink] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [itemCell.activityIndicator stopAnimating];
        if (error) {
            NSLog(@"error to download image for item %@",item.title);
        }
    }];
    return itemCell;
}
#pragma  mark -UiCollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GoodModel *item = self.raenAPI.currentSubcategoryItems[indexPath.row];
    [self performSegueWithIdentifier:@"toItemCardView" sender:item.id];
}
#pragma mark - 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toItemCardView"]) {
        ItemCardViewController *itemCardVC =[segue destinationViewController];
       // itemCardVC.itemID = sender;
        [self.raenAPI getItemCardWithId:sender];
        [[NSNotificationCenter defaultCenter] addObserver:itemCardVC selector:@selector(showItem) name:RaenAPIGotCurrentItem object:self.raenAPI];
        
    }
}

@end
