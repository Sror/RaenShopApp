//
//  TVController.m
//  raenapp
//
//  Created by Alexey Ivanov on 16.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "TVController.h"
#import "TVCell.h"
#import "CVCell.h"
#import "JSONModelLib.h"
#import "GoodModel.h"
#import "CategoryModel.h"
#import "ChildrenModel.h"
#import "ItemCardViewController.h"
#import "GridItemsVC.h"
#import "MBProgressHUD.h"
#import "CategoryItemsGridViewController.h"
#import "UIImageView+WebCache.h"

#import "RaenAPICommunicator.h"

@interface TVController ()<RaenAPICommunicatorDelegate> {
    NSArray *_categories;
    RaenAPICommunicator *_communicator;
}

@end

@implementation TVController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    [self setupRefreshControl];
    [self performSelectorOnMainThread:@selector(refreshView:) withObject:nil waitUntilDone:YES];
}

#pragma mark - RefreshControl
-(void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}
- (void)refreshView:(UIRefreshControl *)sender {
    [self updateDataFromModel];

}
-(void)updateDataFromModel{
    _categories = nil;
    [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    [_communicator getAllCategories];
}
#pragma mark - RaenAPICommunicatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
    
}
-(void)didReceiveAllCategories:(NSArray *)array{
    [MBProgressHUD hideHUDForView:self.tableView animated:YES];
    _categories = array;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tvCell";
    TVCell *tvCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CategoryModel *category = _categories[indexPath.row];
    tvCell.categoryLabel.text = category.title;
    tvCell.categoryLabel.tag = indexPath.row;
    UITapGestureRecognizer *tapOnLabel = [[UITapGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleLabelTap:)];
    tapOnLabel.numberOfTapsRequired = 1;
    [tvCell.categoryLabel addGestureRecognizer:tapOnLabel];

    return tvCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TVCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    
}

#pragma mark - UICollectionViewDataSource Methods
-(NSInteger)collectionView:(IndexedCV *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CategoryModel *category=_categories[collectionView.index];
    return category.childrens.count;
};

-(UICollectionViewCell *)collectionView:(IndexedCV *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCell *cvCell = (CVCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    //[cvCell.label.layer setCornerRadius:5.0];
    CategoryModel *category=_categories[collectionView.index];
    ChildrenModel *children = category.childrens[indexPath.row];
    cvCell.label.text = children.title.uppercaseString;
    [cvCell.activityIndicator startAnimating];
    [cvCell.imageView setImageWithURL:[NSURL URLWithString:children.imageLink]
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType){
        [cvCell.activityIndicator stopAnimating];
        if (error) {
            NSLog(@"error to load image %@",error.localizedDescription);
        }
    }];
    return cvCell;
}
#pragma mark - UITableViewDelegate Methods
/*
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section ==0 ? 120 : 160;
}
*/
#pragma mark UICollectionView delegate
-(void)collectionView:(IndexedCV *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexedCV #%d, did selectItem at row %d",collectionView.index,indexPath.row);
    CategoryModel *category=_categories[collectionView.index];
    ChildrenModel *subCategory = category.childrens[indexPath.row];
    [self performSegueWithIdentifier:@"toGridItemsVC" sender:subCategory.id];
}



#pragma mark - Handle Label Tap
-(void)handleLabelTap:(UITapGestureRecognizer*)tapGestureRecognizer{
    NSInteger row = tapGestureRecognizer.view.tag;
    NSLog(@"tapped on %d label",row);
    CategoryModel *category = _categories[row];
    NSLog(@"category.id %@",category.id);
    [self performSegueWithIdentifier:@"toCategoryItemsGridVC" sender:category.id];
    
}

#pragma mark -Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"toItemCardView"]) {
        ItemCardViewController *itemCardVC=segue.destinationViewController;
        itemCardVC.itemID = sender;
    }
    if ([segue.identifier isEqualToString:@"toGridItemsVC"]) {
        GridItemsVC *gridItemsVC = segue.destinationViewController;
        gridItemsVC.subcategoryID = sender;
    }
    
//    if ([segue.identifier isEqualToString:@"toBrowser"]) {
//        BrowserViewController *browserVC = segue.destinationViewController;
//        browserVC.link = sender;
//    }
    if ([segue.identifier isEqualToString:@"toCategoryItemsGridVC"]) {
        CategoryItemsGridViewController *categoryItemsGridVC = segue.destinationViewController;
        categoryItemsGridVC.currentCategoryId = sender;
    }
}


@end
