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
#import "TOWebViewController.h"
#import "NewsCell.h"
#import "MBProgressHUD.h"
//slider
#import "MainSliderCell.h"
#import "SliderModel.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"

@interface NewsViewController ()<RaenAPICommunicatorDelegate>{
    RaenAPICommunicator* _communicator;
    NSMutableArray *_news;
    NSArray *_sliderItems;
    BOOL _gotNews;
    BOOL _gotSlider;
}

@end

@implementation NewsViewController

-(void)viewDidAppear:(BOOL)animated{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"News Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    [_communicator getItemsFromCart];
    
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _gotNews = NO;
    [_communicator getNewsByPage:1];
    _gotSlider = NO;
    [_communicator getSliderItems];
}


#pragma mark - RaenAPICommunicatorDelegate Methods
-(void)fetchingFailedWithError:(JSONModelError *)error{
#warning TODO: show alert view only ONCE!
    [self.refreshControl endRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
   
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                    message:@"Нет доступа к интернету. Повторите попытку позже"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    if (!alert.isVisible) {
        [alert show];
    }
    
    [self.tableView reloadData];
}

-(void)updateTableView{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    NSInteger rowToScroll = _news.count-10;
    NSIndexPath *firstNewIndexPath = [NSIndexPath indexPathForRow:rowToScroll inSection:1];
    if (rowToScroll != 0) {
        [self.tableView scrollToRowAtIndexPath:firstNewIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    
}
-(void)didReceiveNews:(NSArray *)news{
    _gotNews = YES;
    [_news addObjectsFromArray:news];
    if (_gotSlider){
        [self updateTableView];
    }
}

-(void)didReceiveSliderItems:(NSArray *)array{
    _gotSlider= YES;
    _sliderItems = array;
    if (_gotNews) {
        [self updateTableView];
    }
}
//Update cart tabbar icon
-(void)didReceiveCartItems:(NSArray *)items
{
    [self.tabBarController.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%lu",(unsigned long)items.count]];
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
        [self setImagesInScrollview:sliderCell.scrollView];
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
    
    TOWebViewController *webBrowser = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:news.link]];
    webBrowser.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webBrowser] animated:YES completion:nil];
    
  
//    webBrowser.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:webBrowser animated:YES];
   
}
#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    float endScrolling = scrollView.contentOffset.y +scrollView.frame.size.height;
    if (endScrolling >= scrollView.contentSize.height) {
        NSInteger page = _news.count/RaenAPIdefaultNewsItemsCountPerPage+1;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_communicator getNewsByPage:page];
    }
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    return YES;
}
#pragma mark - Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
}

#pragma mark - Slider Helpers
- (NSInteger)imagesCountInSliderItems{
    NSInteger count = 0;
    for (SliderModel *slider in _sliderItems) {
        if (slider.image) {
            count ++;
        }
    }
    return count;
}
-(void)setScrollViewSize:(UIScrollView*)scrollview withPages:(NSInteger)pages {
    CGSize pagesScrollViewSize = scrollview.frame.size;
    scrollview.contentSize = CGSizeMake(pagesScrollViewSize.width *pages, pagesScrollViewSize.height);
}

-(void)setImagesInScrollview:(UIScrollView*)scrollview{
    //set new images
    for (int i=0;i<[self imagesCountInSliderItems];i++) {
        CGRect frame = scrollview.bounds;
        frame.origin.x = frame.size.width * i;
        frame.origin.y = 0.0f;
        UIImageView *imageView =[[UIImageView alloc] initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = i;
        imageView.userInteractionEnabled = YES;
        [scrollview addSubview:imageView];
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [spinner setCenter:imageView.center];
        [spinner setHidesWhenStopped:YES];
        [scrollview addSubview:spinner];
        imageView.tag = i;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [spinner startAnimating];
        SliderModel *slide = _sliderItems[i];
        [imageView setImageWithURL:[NSURL URLWithString:slide.image]
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                             [spinner stopAnimating];
                         }];
    
        UITapGestureRecognizer *tapOnSlider = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(handleSlideTap:)];
        tapOnSlider.numberOfTapsRequired = 1;
        tapOnSlider.numberOfTouchesRequired = 1;
        [imageView addGestureRecognizer:tapOnSlider];
        
    }
    
}

-(void)handleSlideTap:(UITapGestureRecognizer*)tapGestureRecognizer
{
    SliderModel *slider = _sliderItems[tapGestureRecognizer.view.tag];
    if ([slider.action isEqualToString:@"toBrowser"]) {
        
        TOWebViewController *webBrowser = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:slider.link]];
        webBrowser.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webBrowser] animated:YES completion:nil];
        
        
    }else if ([slider.action isEqualToString:@"toItemCardView"]){
        [self performSegueWithIdentifier:@"toItemCardView" sender:slider.id];
        
    }else if ([slider.action isEqualToString:@"toSaleOfDay"]){
        [self performSegueWithIdentifier:@"toSaleOfDay" sender:nil];
    }else if ([slider.action isEqualToString:@"toSubcategoryItemsVC"]){
        [self performSegueWithIdentifier:@"toSubcategoryItemsVC" sender:slider.id];
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
