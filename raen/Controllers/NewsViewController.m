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
    NSArray *_news;
    RaenAPICommunicator *_communicator;
}

@end

@implementation NewsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    [_communicator setDelegate:self];
    [_communicator getNews];
    [HUD showUIBlockingIndicator];
	[self.tableView setHidden:YES];
    self.navigationItem.title = @"Загрузка...";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - RaenAPICommunicatorDelegate Methods
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

-(void)didReceiveNews:(NSArray *)news{
    NSLog(@"didReceive %d news category",news.count);
    [HUD hideUIBlockingIndicator];
    _news = news;
    [self.tableView reloadData];
    [self.tableView setHidden:NO];
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
