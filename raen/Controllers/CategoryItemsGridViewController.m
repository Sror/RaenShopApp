//
//  CategoryItemsGridViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 08.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "CategoryItemsGridViewController.h"
#import "RaenAPICommunicator.h"
#import "GridCategoryItemCell.h"
#import "ChildrenModel.h"
#import "GridItemsVC.h"
#import "UIImageView+WebCache.h"

@interface CategoryItemsGridViewController ()<RaenAPICommunicatorDelegate>{
    RaenAPICommunicator *_communicator;
    NSArray *_items;
}

@end

@implementation CategoryItemsGridViewController
@synthesize currentCategoryId=_currentCategoryId;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator=[[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
   
    NSLog(@"_currentCategoryId in ViewDidLoad %@",_currentCategoryId);
    [self setupRefreshControl];
    if (_currentCategoryId) {
        [self performSelectorOnMainThread:@selector(refreshView:) withObject:nil waitUntilDone:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIRefreshControl
-(void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:self.refreshControl];
}
- (void)refreshView:(UIRefreshControl *)sender {
    
    [_communicator getAllCategories];

}
#pragma mark - RaenAPICommunicatorDelegate Methods
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [self.refreshControl endRefreshing];
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Ошибка!" message:@"Проверьте подключение к интернету" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
}
-(void)didReceiveAllCategories:(NSArray *)array{
    NSLog(@"didReceiveAllCategories");
    for (CategoryModel *category in array) {
        if ([category.id isEqualToString:_currentCategoryId]) {
            _items = category.childrens;
            [self.collectionView reloadData];
            [self.refreshControl endRefreshing];
        }
    }
}
#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _items.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    GridCategoryItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"categoryItemsCell"
                                                                          forIndexPath:indexPath];
    ChildrenModel *children = _items[indexPath.row];
    cell.mainLabel.text = children.title;
    [cell.spinner startAnimating];
    [cell.imageView setImageWithURL:[NSURL URLWithString:children.imageLink] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [cell.spinner stopAnimating];
    }];
    return  cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ChildrenModel *subCategory = _items[indexPath.row];
    [self performSegueWithIdentifier:@"toGridItemsVC" sender:subCategory.id];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"toGridItemsVC"]) {
        GridItemsVC *gridItemsVC = segue.destinationViewController;
        gridItemsVC.subcategoryID = sender;
    }
}
@end
