//
//  GridItemsVC.m
//  raenapp
//
//  Created by Alexey Ivanov on 30.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "GridItemsVC.h"
#import "ItemCell.h"
#import "SubcategoryModel.h"
#import "GoodModel.h"
#import "UIImageView+WebCache.h"
#import "ItemCardViewController.h"
#import "RaenAPICommunicator.h"
#import "FiltersViewController.h"
#import "HUD.h"

@interface GridItemsVC ()<RaenAPICommunicatorDelegate,FiltersViewControllerDelegate>
{   RaenAPICommunicator *_communicator;
    NSInteger _itemsCount;
    NSMutableArray *_items;
}

@end

@implementation GridItemsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    _items = [NSMutableArray array];
    [self setupRefreshControl];
    if (self.subcategoryID) {
        [self performSelectorOnMainThread:@selector(refreshView:) withObject:nil waitUntilDone:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}
- (void)refreshView:(UIRefreshControl *)sender {
    [_items removeAllObjects];
    [HUD showUIBlockingIndicator];
    [_communicator getSubcategoryWithId:self.subcategoryID withParameters:nil];
    
}
#pragma mark - RaenAPICOmmunicationDelegate 
-(void)didReceiveSubcategory:(id)subcategoryModel{
    NSLog(@"didReceiveSubcategory");
    if ([subcategoryModel isKindOfClass:[SubcategoryModel class]]) {
        SubcategoryModel *subcategory  = subcategoryModel;
        _itemsCount = subcategory.count;
        if (_itemsCount==0) {
        }
        [_items addObjectsFromArray:subcategory.goods];
        [HUD hideUIBlockingIndicator];
        [self.navigationItem setTitle:@"Товары"];
        [self.collectionView reloadData];
        [self.refreshControl endRefreshing];
    }
    NSLog(@"\n_items.count = %d\n _itemsCount=%d",_items.count,_itemsCount);
}

-(void)fetchingFailedWithError:(JSONModelError *)error{
    [self.refreshControl endRefreshing];
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}

#pragma mark -FiltersViewControllerDelegate method
-(void)didSelectFilter:(NSDictionary *)filterParameters{
    NSLog(@"didSelectFilter %@",filterParameters);
    [_items removeAllObjects];
    [_communicator getSubcategoryWithId:self.subcategoryID withParameters:filterParameters];
}

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
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    float endScrolling = scrollView.contentOffset.y +scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height) {
        NSLog(@"Scroll END Called!");
        if (_items.count < _itemsCount) {
            NSInteger page = _items.count/RaenAPIdefaulSubcategoryItemsCountPerPage+1;
             NSLog(@"currentPage %d",page);
           [_communicator getSubcategoryWithId:self.subcategoryID withParameters:@{@"page":[NSNumber numberWithInteger:page]}];
        [HUD showUIBlockingIndicator];
        }
    }
}

#pragma mark - 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toItemCardView"])
    {
        ItemCardViewController *itemCardVC=segue.destinationViewController;
        itemCardVC.itemID = sender;
    }
    if ([segue.identifier isEqualToString:@"toFiltersVC"])
    {
        UINavigationController *navigationVC = segue.destinationViewController;
        FiltersViewController *filtersVC = [[navigationVC viewControllers] objectAtIndex:0];
        filtersVC.delegate = self;
        if ([sender isKindOfClass:[NSString class]]) {
            filtersVC.subcategoryID = sender;
        }else{
            NSLog(@"unknow sender's class sent to filters view controller");
        }
        
    }

}
- (IBAction)filterButtonPressed:(id)sender {
    
    [self performSegueWithIdentifier:@"toFiltersVC" sender:self.subcategoryID];
}

@end
