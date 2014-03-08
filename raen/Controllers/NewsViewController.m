//
//  NewsViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "NewsViewController.h"
#import "RaenAPICommunicator.h"
#import "HUD.h"
#import "NewsModel.h"
#import "UIImageView+WebCache.h"
#import "BrowserViewController.h"
#import "NewsCell.h"

@interface NewsViewController ()<RaenAPICommunicatorDelegate>{
    NSMutableArray *_news;
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
    [HUD showUIBlockingIndicator];
    [_communicator getNewsByPage:1];
    
}
-(void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}
- (void)refreshView:(UIRefreshControl *)sender {
    [_news removeAllObjects];
    [HUD showUIBlockingIndicator];
    [_communicator getNewsByPage:1];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_news removeAllObjects];
    // Dispose of any resources that can be recreated.
}
#pragma mark - RaenAPICommunicatorDelegate Methods
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [self.refreshControl endRefreshing];
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

-(void)didReceiveNews:(NSArray *)news{
    NSLog(@"didReceive %d news",news.count);
    [self.refreshControl endRefreshing];
    [HUD hideUIBlockingIndicator];
    [_news  addObjectsFromArray:news];
    [self.tableView reloadData];
    self.navigationItem.title = @"Новости";
}
#pragma mark - UITableViewDataSource Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _news.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    //one news in each section
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newsCell"];
    NewsModel *currentNews = _news[indexPath.section];
    cell.titlelabel.text = currentNews.title;
    if ([currentNews.image rangeOfString:@"http"].location !=NSNotFound) {
        [cell.spinner startAnimating];
        [cell.newsImageView setImageWithURL:[NSURL URLWithString:currentNews.image]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            [cell.spinner stopAnimating];
        }];
    }
    [cell.descriptionWebView loadHTMLString:currentNews.text baseURL:nil];
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NewsModel *news = _news[section];
    return news.type;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NewsModel *news = _news[indexPath.section];
    [self performSegueWithIdentifier:@"toBrowser" sender:news];
}
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    if (maximumOffset - currentOffset <= 50) {
        NSLog(@"reload");
        //TODO
        NSInteger page = _news.count/10+1;
        NSLog(@"page %d",page);
        [_communicator getNewsByPage:page];
    }
}

#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
    if ([segue.identifier isEqualToString:@"toBrowser"]) {
        BrowserViewController *browserVC = segue.destinationViewController;
        NewsModel *news = sender;
        [browserVC setLink:news.link];
        [browserVC setTitle:news.title];
    }
}
@end
