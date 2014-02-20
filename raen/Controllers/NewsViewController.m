//
//  NewsViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 20.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//
#import "HUD.h"
#import "NewsViewController.h"
#import "IndexedCV.h"
#import "TVCell.h"
#import "CVCell.h"
#import "BrowserViewController.h"

#import "NewsCategoryModel.h"
#import "NewsModel.h"

#import "RaenAPICommunicator.h"

#import "UIImageView+WebCache.h"

@interface NewsViewController ()<RaenAPICommunicatorDelegate>{
     RaenAPICommunicator *_communicator;
    NSArray *_news;
}

@end

@implementation NewsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self.tableView setDelegate:self];
    //[self.tableView setDataSource:self];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    [self updateDataFromModel];
    
}
-(void)updateDataFromModel{
    _news = nil;
    [HUD showUIBlockingIndicatorWithText:@"Loading..."];
    [_communicator getNews];
    
}
-(void)didReceiveNews:(NSArray *)news{
    NSLog(@"did receive %i news categories",news.count);
    _news = news;
    [HUD hideUIBlockingIndicator];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -RaenApiDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _news.count;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tvCell";
    TVCell *tvCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NewsCategoryModel *newsCategory = _news[indexPath.row];
    tvCell.label.text = newsCategory.title;
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
    NewsCategoryModel *newsCategory=_news[collectionView.index];
    return newsCategory.news.count;
};

-(UICollectionViewCell *)collectionView:(IndexedCV *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CVCell *cvCell =[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    [cvCell.label.layer setCornerRadius:5.0];
    NewsCategoryModel *newsCategory=_news[collectionView.index];
    NewsModel *newsInCategory =newsCategory.news[indexPath.row];
    cvCell.label.text = newsInCategory.title;
   [cvCell.imageView setImageWithURL:[NSURL URLWithString:newsInCategory.image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
       if (error) {
           NSLog(@"error to load image %i in collectionView %i",indexPath.row,collectionView.index);
       }
   }];
    return cvCell;
}
#pragma mark uiCollectionView delegate
-(void)collectionView:(IndexedCV *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexedCV %lu, did selectItem at row %lu",collectionView.index,indexPath.row);
    NewsCategoryModel *newsCategory=_news[collectionView.index];
    NewsModel *newsInCategory =newsCategory.news[indexPath.row];
    if ([newsInCategory.link rangeOfString:@"http"].location !=NSNotFound) {
        [self performSegueWithIdentifier:@"toBrowser" sender:newsInCategory.link];
    }else{
        NSLog(@"bad news url to blog!");
    }
    
    
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toBrowser"]) {
       BrowserViewController *browserVC= segue.destinationViewController;
        
        browserVC.link = sender;
    }
}
@end
