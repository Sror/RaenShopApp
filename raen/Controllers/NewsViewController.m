//
//  NewsViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "NewsViewController.h"
#import "RaenAPICommunicator.h"
#import "NewsModel.h"
#import "UIImageView+WebCache.h"
#import "BrowserViewController.h"
#import "NewsCell.h"
#import "HUD.h"
//slider
#import "MainSliderCell.h"
#import "SliderModel.h"


@interface NewsViewController ()<RaenAPICommunicatorDelegate>{
    NSMutableArray *_news;
    NSArray *_sliderItems;
    RaenAPICommunicator *_communicator;
}

@end

@implementation NewsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    [_communicator setDelegate:self];
    [self setupRefreshControl];
    _news = [NSMutableArray array];
    [self performSelectorOnMainThread:@selector(refreshView:) withObject:nil waitUntilDone:YES];
}

#pragma mark - UIRefreshControl
-(void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)refreshView:(UIRefreshControl *)sender {
    [_news removeAllObjects];
    [HUD showUIBlockingIndicator];
    [_communicator getNewsByPage:1];
    [_communicator getSliderItems];
}

#pragma mark - RaenAPICommunicatorDelegate Methods
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [self.refreshControl endRefreshing];
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

-(void)didReceiveNews:(NSArray *)news{
    NSLog(@"didReceive %d news",news.count);
    [self.refreshControl endRefreshing];
    [HUD hideUIBlockingIndicator];
    [_news  addObjectsFromArray:news];
    [self.tableView reloadData];
}

-(void)didReceiveSliderItems:(NSArray *)array{
    NSLog(@"didReceiveSliderItems");
    _sliderItems = array;
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
}
#pragma mark - UITableViewDataSource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }
    return _news.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
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
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell"];
    NewsModel *currentNews = _news[indexPath.row];
    cell.titlelabel.text = currentNews.title;
    cell.categoryLabel.text = currentNews.type;
    if ([currentNews.image rangeOfString:@"http"].location !=NSNotFound) {
        [cell.spinner startAnimating];
        [cell.newsImageView setImageWithURL:[NSURL URLWithString:currentNews.image]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [cell.spinner stopAnimating];
        }];
    }
    cell.descriptionLabel.text = currentNews.text;
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewsModel *news = _news[indexPath.row];
    [self performSegueWithIdentifier:@"toBrowser" sender:news.link];
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSLog(@"scrollViewDidEndDecelerating");
    float endScrolling = scrollView.contentOffset.y +scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height) {
        NSLog(@"Scroll END Called!");
        NSInteger page = _news.count/RaenAPIdefaultNewsItemsCountPerPage+1;
        NSLog(@"page %d",page);
        [HUD showUIBlockingIndicator];
        [_communicator getNewsByPage:page];
    }
}

#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"toBrowser"]) {
        UINavigationController *navigationVC = segue.destinationViewController;
        BrowserViewController *browserVC = [[navigationVC viewControllers] objectAtIndex:0];
        [browserVC setLink:sender];
    }
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
#pragma mark - Memory Warning 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_news removeAllObjects];
    [self.tableView reloadData];
    // Dispose of any resources that can be recreated.
}
@end
