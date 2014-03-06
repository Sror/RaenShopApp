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
#import "SliderModel.h"
#import "MainSliderCell.h"
#import "SliderModel.h"
#import "BrowserViewController.h"

#import "UIImageView+WebCache.h"

#import "RaenAPICommunicator.h"

@interface TVController ()<RaenAPICommunicatorDelegate> {
    NSArray *_categories;
    NSArray *_sliderItems;
    RaenAPICommunicator *_communicator;
    BOOL didReceiveAllCategories;
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
    didReceiveAllCategories = NO;
    [self.tableView reloadData];
    [HUD showUIBlockingIndicatorWithText:@"Loading..."];
    [_communicator getAllCategories];
    [_communicator getSliderItems];

}
#pragma mark - RaenAPICommunicatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    didReceiveAllCategories = NO;
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
    
}
-(void)didReceiveAllCategories:(NSArray *)array{
    NSLog(@"didReceiveAllCategories");
    didReceiveAllCategories = YES;
    [HUD hideUIBlockingIndicator];
    _categories = array;
    [self.tableView reloadData];
    //[self reloadTableViewWithAnimation:YES];
}
-(void)didReceiveSliderItems:(NSArray *)array{
    NSLog(@"didReceiveSliderItems");
    _sliderItems = array;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    
}
-(void)reloadTableViewWithAnimation:(BOOL)animation{
    if (animation) {
        [self.tableView reloadData];
        [self.tableView numberOfRowsInSection:_categories.count];
        NSMutableArray *evenIndexPaths = [NSMutableArray array];
        NSMutableArray *oddIntexPath= [NSMutableArray array];
        for (int i =0; i<_categories.count; i++) {
            NSIndexPath *indexPath= [NSIndexPath indexPathForRow:i inSection:1];
            if (i % 2==0) {
                [evenIndexPaths addObject:indexPath];
            }else{
                [oddIntexPath addObject:indexPath];
            }
        }
        [self.tableView reloadRowsAtIndexPaths:evenIndexPaths withRowAnimation:UITableViewRowAnimationLeft];
        [self.tableView reloadRowsAtIndexPaths:oddIntexPath withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return _categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"tableView cellForRowAtIndexPath");
    if (indexPath.section ==0) {
        MainSliderCell *sliderCell = [tableView dequeueReusableCellWithIdentifier:@"sliderCell"];
        NSInteger imagesCount =[self imagesCountInSliderItems];
        [self setScrollViewSize:sliderCell.scrollView withPages:imagesCount];
        sliderCell.pageControl.numberOfPages = imagesCount;
        //sliderCell.selectionStyle = UITableViewCellSelectionStyleNone;
        //load images in scrollview
        for (NSInteger i=0; i<imagesCount; i++) {
            [self loadPage:i forScrollView:sliderCell.scrollView withSpinner:sliderCell.spinner];
        }
        return sliderCell;
    }
    static NSString *CellIdentifier = @"tvCell";
    TVCell *tvCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    CategoryModel *category = _categories[indexPath.row];
    tvCell.categoryLabel.text = category.title;
    [tvCell.categoryLabel setTag:indexPath.row];
    //[tvCell.categoryLabel addTarget:self action:@selector(categoryButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return tvCell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TVCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"willDisplayCell");
    if (indexPath.section ==1) {
        [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    }
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
    [cvCell.label.layer setCornerRadius:5.0];
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section ==0 ? 120 : 160;
}

#pragma mark UICollectionView delegate
-(void)collectionView:(IndexedCV *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"indexedCV #%d, did selectItem at row %d",collectionView.index,indexPath.row);
    CategoryModel *category=_categories[collectionView.index];
    ChildrenModel *subCategory = category.childrens[indexPath.row];
    [self performSegueWithIdentifier:@"toGridItemsVC" sender:subCategory.id];
}

#pragma mark - Slider Helpers
- (NSInteger)imagesCountInSliderItems{
    NSInteger count = 0;
    for (SliderModel *slider in _sliderItems) {
        if (slider.image) {
            count ++;
        }
    }
    NSLog(@"%i images in sliderItem",count);
    return count;
}
-(void)setScrollViewSize:(UIScrollView*)scrollview withPages:(NSInteger)pages {
    CGSize pagesScrollViewSize = scrollview.frame.size;
    scrollview.contentSize = CGSizeMake(pagesScrollViewSize.width *pages, pagesScrollViewSize.height);
    
}
-(void)loadPage:(NSInteger)page forScrollView:(UIScrollView*)scrollView withSpinner:(UIActivityIndicatorView*)spinner {
    CGRect frame = scrollView.bounds;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0.0f;
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:frame];
    //NSLog(@"current imageView frame x=%f , y=%f",frame.origin.x,frame.origin.y);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.tag = page;
    imageView.userInteractionEnabled = YES;
    [scrollView addSubview:imageView];
    [spinner startAnimating];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    SliderModel *slider = _sliderItems[page];

    [imageView setImageWithURL:[NSURL URLWithString:slider.image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [spinner stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];

    UITapGestureRecognizer *tapOnSlider = [[UITapGestureRecognizer alloc]
                                     initWithTarget:self action:@selector(handleSlideTap:)];
    tapOnSlider.numberOfTapsRequired = 1;
    [imageView addGestureRecognizer:tapOnSlider];
    
}
-(void)handleSlideTap:(UITapGestureRecognizer*)tapGestureRecognizer{
    NSLog(@"Taped slide #%d", tapGestureRecognizer.view.tag);
    SliderModel *slider = _sliderItems[tapGestureRecognizer.view.tag];
    NSLog(@"slider action %@",slider.action);
    if ([slider.action isEqualToString:@"toBrowser"]) {
        [self performSegueWithIdentifier:@"toBrowser" sender:slider.link];
    }else if ([slider.action isEqualToString:@"toItemCardView"]){
        [self performSegueWithIdentifier:@"toItemCardView" sender:slider.id];
    }else if ([slider.action isEqualToString:@"toSaleOfDay"]){
//TODO sender
        [self performSegueWithIdentifier:@"toSaleOfDay" sender:nil];
    }else if ([slider.action isEqualToString:@"toGridItemsVC"]){
        [self performSegueWithIdentifier:@"toGridItemsVC" sender:slider.id];
    }

}
#pragma mark - Helpers
-(void)categoryButtonPressed:(id)sender{
    NSInteger row = [sender tag];
    NSLog(@"tapped categoryButton at row %i",row);
}
#pragma mark -Prepare Segue
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
    if ([segue.identifier isEqualToString:@"toBrowser"]) {
        BrowserViewController *browserVC = segue.destinationViewController;
        browserVC.link = sender;
    }
}


@end
