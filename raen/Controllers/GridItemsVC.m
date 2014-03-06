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

#import "RaenAPICommunicator.h"

@interface GridItemsVC ()<RaenAPICommunicatorDelegate>
{   RaenAPICommunicator *_communicator;
    NSArray *_items;
}

@end

@implementation GridItemsVC



- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    [_communicator getSubcategoryWithId:self.subcategoryID];
    [HUD showUIBlockingIndicatorWithText:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - RaenAPICOmmunicationDelegate 
-(void)didReceiveSubcategoryItems:(NSArray *)items{
    
    _items = items;
    [self.navigationItem setTitle:@"Товары"];
    [self.collectionView reloadData];
    [HUD hideUIBlockingIndicator];
    
}
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}
#pragma mark UICollectionViewDataSource
#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
};

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CollectionViewCellIdentifier = @"itemCell";
    ItemCell *itemCell = (ItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier
                                                                              forIndexPath:indexPath];
    GoodModel *item = _items[indexPath.row];
    itemCell.titleLabel.text = item.title;
    [itemCell.activityIndicator startAnimating];
    //PRICE LABELS
    if (item.priceNew.length>2) {
        itemCell.priceLabel.text =  [NSString stringWithFormat:@"%@ Руб.",item.priceNew];
        itemCell.oldPriceLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ Руб.",item.price]
                                                                                attributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
       // itemCell.oldPriceLabel.text = [NSString stringWithFormat:@"%@ Руб.",item.price];
    }else{
        itemCell.priceLabel.text = @"";
        itemCell.oldPriceLabel.text = [NSString stringWithFormat:@"%@ Руб.",item.price];
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
    GoodModel *item = _items[indexPath.row];
    [self performSegueWithIdentifier:@"toItemCardView" sender:item.id];
}
#pragma mark - 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toItemCardView"]) {
        
        ItemCardViewController *itemCardVC=segue.destinationViewController;
        itemCardVC.itemID = sender;
        
        //[self.raenAPI getItemCardWithId:sender];
        //[_communicator getItemCardWithId:sender];
        
    }
}

@end
