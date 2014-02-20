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
    
    //set refresh button
    UIBarButtonItem *refreshButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateDataFromModel)];
    [self.navigationItem setRightBarButtonItem:refreshButton];
    
    [self updateDataFromModel];

}
-(void)updateDataFromModel{
    _categories = nil;
    [HUD showUIBlockingIndicatorWithText:@"Loading..."];
    [_communicator getAllCategories];

}
#pragma mark - RaenAPICommunicatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
    
}
-(void)didReceiveAllCategories:(NSArray *)array{
    NSLog(@"didReceiveAllCategories");
    [HUD hideUIBlockingIndicator];
    _categories = array;
    //[self.tableView reloadData];
    [self reloadTableViewWithAnimation:YES];
}
-(void)reloadTableViewWithAnimation:(BOOL)animation{
    if (animation) {
        [self.tableView reloadData];
        [self.tableView numberOfRowsInSection:_categories.count];
        NSMutableArray *evenIndexPaths = [NSMutableArray array];
        NSMutableArray *oddIntexPath= [NSMutableArray array];
        for (int i =0; i<_categories.count; i++) {
            NSIndexPath *indexPath= [NSIndexPath indexPathForRow:i inSection:0];
            if (i % 2==0) {
                [evenIndexPaths addObject:indexPath];
            }else{
                [oddIntexPath addObject:indexPath];
            }
        }
        [self.tableView reloadRowsAtIndexPaths:evenIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadRowsAtIndexPaths:oddIntexPath withRowAnimation:UITableViewRowAnimationRight];
        //[self.tableView endUpdates];
    }
    else{
        [self.tableView reloadData];
    }
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
    
    return _categories.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tvCell";
    TVCell *tvCell = (TVCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!tvCell) {
        tvCell = [[TVCell alloc] initWithStyle:UITableViewCellStyleDefault
                              reuseIdentifier:CellIdentifier];
    }
    CategoryModel *category = _categories[indexPath.row];
    tvCell.label.text = category.title;
    return tvCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TVCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    NSInteger index = cell.collectionView.index;

}

#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(IndexedCV *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CategoryModel *category=_categories[collectionView.index];
    /*
    if ([category.id isEqualToString:@"26"]) {
       return self.raenAPI.bikes.count;
    }
    if ([category.id isEqualToString:@"74"]) {
        return self.raenAPI.guards.count;
    }
     */
    return category.childrens.count;
};

-(UICollectionViewCell *)collectionView:(IndexedCV *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCell *cvCell = (CVCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    [cvCell.label.layer setCornerRadius:5.0];
    CategoryModel *category=_categories[collectionView.index];
    /*
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
    */
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
   
    CategoryModel *category=_categories[collectionView.index];
    /*
    if([category.id isEqualToString:@"74"])
    {
        GoodModel *guardItem = self.raenAPI.guards[indexPath.row];
        [self performSegueWithIdentifier:@"toItemCardView" sender:guardItem.id];
    }*/
     //else
    
        ChildrenModel *subCategory = category.childrens[indexPath.row];
        [self performSegueWithIdentifier:@"toGridItemsVC" sender:subCategory];
    
    
}
#pragma mark -Prepare Segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toItemCardView"]) {
        ItemCardViewController *itemCardVC=segue.destinationViewController;
        itemCardVC.itemID = sender;
       
    }
    if ([segue.identifier isEqualToString:@"toGridItemsVC"]) {
        GridItemsVC *gridItemsVC = segue.destinationViewController;
        ChildrenModel *subCategory = sender;
        gridItemsVC.subcategoryID = subCategory.id;
        gridItemsVC.navigationItem.title =subCategory.title;
    }
}

@end
