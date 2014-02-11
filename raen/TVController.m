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
#import "HUD.h"
#import "JSONModelLib.h"
#import "GoodModel.h"
#import "CategoryModel.h"
#import "ChildrenModel.h"
#import "ItemCardViewController.h"
#import "GridItemsVC.h"

#import "UIImageView+WebCache.h"

#define kRaenUrlBikes @"http://raenshop.ru/api/catalog/goods_list/cat_id/26/" //complete bikes
#define kRaenUrlGuardItems @"http://raenshop.ru/api/catalog/goods_list/cat_id/81/" //guard
#define kRaenURlCategories @"http://raenshop.ru/api/catalog/categories"

@interface TVController () {

}

@end

@implementation TVController


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    self.raenAPI = [[AppDelegate instance] raenAPI];
    //set refresh button
    UIBarButtonItem *refreshButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateDataFromModel)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    [self updateDataFromModel];

}
-(void)updateDataFromModel{
    [HUD showUIBlockingIndicatorWithText:@"Loading..."];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(bikesReady:) name:RaenAPIGotBikes object:self.raenAPI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoriesReady:) name:RaenAPIGotCategories object:self.raenAPI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(guardsReady:) name:RaenAPIGotGuards object:self.raenAPI];
    [self.raenAPI updateGuards];
    [self.raenAPI updateCategories];
    [self.raenAPI updateBikes];
}
-(void)bikesReady:(NSNotification*)not{
    NSLog(@"remove observer for %@",RaenAPIGotBikes);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RaenAPIGotBikes object:self.raenAPI];
    NSIndexPath *bikesIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[bikesIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    //[self.tableView reloadData];
    [HUD showTimedAlertWithTitle:@"Succes" text:@"to get bikes" withTimeout:1];
    
}
-(void)categoriesReady:(NSNotification*)not{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RaenAPIGotCategories object:self.raenAPI];
    //[self.tableView reloadData];
    NSMutableArray *muArray = [[NSMutableArray alloc] init];
    for (int i=0; i<self.raenAPI.categories.count; i++) {
        NSLog(@"i= %i",i);
        if (i!=0 && i!=2) {
            NSIndexPath *indexPath =[NSIndexPath indexPathForRow:i inSection:0];
            [muArray addObject:indexPath];
            NSLog(@"muarray %@",muArray);
        }
    }
    NSArray *tmpArray = [NSArray arrayWithArray:muArray];
    NSLog(@"tmpArray %@",tmpArray);
    muArray = nil;
    [self.tableView reloadData];
    [self.tableView reloadRowsAtIndexPaths:tmpArray withRowAnimation:UITableViewRowAnimationFade];
    [HUD showTimedAlertWithTitle:@"Succes" text:@"got categories data" withTimeout:1];

}
-(void)guardsReady:(NSNotification*)not{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RaenAPIGotGuards object:self.raenAPI];
    NSIndexPath *guardsIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[guardsIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    //[self.tableView reloadData];
    [HUD showTimedAlertWithTitle:@"Succes" text:@"got categories data" withTimeout:1];
    
}
-(void)viewDidAppear:(BOOL)animated {
    
    
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
    NSLog(@"self.raenAPI.categories.count %i",self.raenAPI.categories.count);
    if (self.raenAPI.categories.count>0) {
        return self.raenAPI.categories.count;
    }else{
        ///returning
        return 10;
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tvCell";
    TVCell *tvCell = (TVCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!tvCell) {
        tvCell = [[TVCell alloc] initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:CellIdentifier];
    }
    CategoryModel *category = self.raenAPI.categories[indexPath.row];
    tvCell.label.text = category.title;
    //tvCell.label.text =[NSString stringWithFormat:@"Новость %d в секции %d",indexPath.row,indexPath.section];
    return tvCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TVCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    NSInteger index = cell.collectionView.index;
   // CGFloat horizontalOffset = [self.contentOffsetDictionary[[@(index) stringValue]] floatValue];
    //[cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(IndexedCV *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CategoryModel *category=self.raenAPI.categories[collectionView.index];
    if ([category.id isEqualToString:@"26"]) {
       return self.raenAPI.bikes.count;
    }
    if ([category.id isEqualToString:@"74"]) {
        return self.raenAPI.guards.count;
    }
    return category.childrens.count;
};

-(UICollectionViewCell *)collectionView:(IndexedCV *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCell *cvCell = (CVCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    [cvCell.label.layer setCornerRadius:5.0];
    CategoryModel *category=self.raenAPI.categories[collectionView.index];
    if ([category.id isEqualToString:@"26"]) {
        GoodModel *bike = self.raenAPI.bikes[indexPath.row];
        cvCell.label.text = bike.title;
        //NSString *tmpImgLink = [NSString stringWithFormat:@"http://raenshop.ru/img/goods/bikes/%@",bike.imageLink];
        //NSLog(@"tmpImgLink %@",tmpImgLink);
        [cvCell.activityIndicator startAnimating];
        [cvCell.imageView setImageWithURL:[NSURL URLWithString:bike.imageLink]
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                    [cvCell.activityIndicator stopAnimating];
                                    if (error) {
                                        NSLog(@"error to load bike image %@",error.localizedDescription);
                                    }
                                }];
        return cvCell;
    }
    if ([category.id isEqualToString:@"74"]) {
        GoodModel *guard =self.raenAPI.guards[indexPath.row];
        cvCell.label.text = guard.title;
        [cvCell.activityIndicator startAnimating];
        [cvCell.imageView setImageWithURL:[NSURL URLWithString:guard.imageLink] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [cvCell.activityIndicator stopAnimating];
            if (error) {
                NSLog(@"error to load Guard Item image %@",error.localizedDescription);
            }
        }];
        return cvCell;
    }
    
    ChildrenModel *children = category.childrens[indexPath.row];
    cvCell.label.text = children.title;
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
#pragma mark uiCollectionView delegate
-(void)collectionView:(IndexedCV *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexedCV #%d, did selectItem at row %d",collectionView.index,indexPath.row);
   /*
    CategoryModel *category=_categories[collectionView.index];
    if ([category.id isEqualToString:@"26"])
    {
        GoodModel *bike=_bikes[indexPath.row];
        [self performSegueWithIdentifier:@"toItemCardView" sender:bike.id];
    }else if([category.id isEqualToString:@"74"])
    {
        GoodModel *guardItem = _guardItems[indexPath.row];
        [self performSegueWithIdentifier:@"toItemCardView" sender:guardItem.id];
    }else
    {
        ChildrenModel *subCategory = category.childrens[indexPath.row];
        [self performSegueWithIdentifier:@"toGridItemsVC" sender:subCategory];
    }
    */
}
#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toItemCardView"]) {
        ItemCardViewController *itemCardVC=segue.destinationViewController;
        itemCardVC.itemID = sender;
    }
    if ([segue.identifier isEqualToString:@"toGridItemsVC"]) {
        GridItemsVC *gridItemsVC = segue.destinationViewController;
        gridItemsVC.subcategory = sender;
    }
}

@end
