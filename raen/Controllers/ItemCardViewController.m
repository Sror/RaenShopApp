//
//  ItemViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ItemCardViewController.h"
#import "HUD.h"
#import "JSONModelLib.h"
#import "ItemModel.h"
#import "ImageModel.h"
#import "ItemCardCell.h"
#import "UIImageView+WebCache.h"

#import "RaenAPICommunicator.h"

@interface ItemCardViewController ()<RaenAPICommunicatorDelegate> {
   // ItemModel *item;
    ItemModel *_item;
    RaenAPICommunicator *_communicator;
}

@end

@implementation ItemCardViewController


-(void)viewDidAppear:(BOOL)animated{
    NSLog(@"ItemCardVC viewDid Appear");
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showItem) name:RaenAPIGotCurrentItem object:self.raenAPI];
   
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setHidden:YES];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    [_communicator getItemCardWithId:self.itemID];
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
}
-(void)viewWillDisappear:(BOOL)animated{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - RaenAPICommunicatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}
-(void)didReceiveItemCard:(id)itemCard{
    NSLog(@"didReceiveItemCard");
    [self.navigationItem setTitle:_item.title];
    [HUD hideUIBlockingIndicator];
    _item = itemCard;
    [self.tableView setHidden:NO];
    [self.tableView reloadData];
}
#pragma  mark - ScrollView
-(void)loadPage:(NSInteger)page forScrollView:(UIScrollView*)scrollView {
    
    CGRect frame = scrollView.bounds;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0.0f;
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:frame];
    //NSLog(@"current imageView frame x=%f , y=%f",frame.origin.x,frame.origin.y);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView];
    ImageModel *image = _item.images[page];
    UIActivityIndicatorView *activityIndicator =[[ UIActivityIndicatorView alloc]
                                                 initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = imageView.center;
    [activityIndicator setHidesWhenStopped:YES];
    [imageView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [imageView setImageWithURL:[NSURL URLWithString:image.big] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [activityIndicator stopAnimating];
        
    }];
}


-(void)setScrollViewSize:(UIScrollView*)scrollview withPages:(NSInteger)pages {
    CGSize pagesScrollViewSize = scrollview.frame.size;
    scrollview.contentSize = CGSizeMake(pagesScrollViewSize.width *pages, pagesScrollViewSize.height);
    
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([_item.review rangeOfString:@"http"].location == NSNotFound){
        return 1;
    }else{
        return 2;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        NSString *itemDescription =[_item.desc stringByReplacingOccurrencesOfString:@"<br>" withString:@"//n"];
        itemDescription = [itemDescription stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        
        
       // CGSize aboutSize = [newAboutText sizeWithFont:font constrainedToSize:CGSizeMake(268, 4000)];
        
        // if deployment target is iOS7 and you want to get rid of the warning above
        // comment the line above and uncomment the following section
        
        // ios 7 only
        CGRect boundingRect = [itemDescription boundingRectWithSize:CGSizeMake(268, 4000)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:font}
                                             context:nil];
        
        CGSize boundingSize = boundingRect.size;
        NSLog(@"boundingSize height %f",boundingRect.size.height);
        // end ios7 only
        
        
        return (240+10+boundingSize.height);

    }
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"indexPath.row %d",indexPath.row);
    if (indexPath.row == 0) {
        static NSString *CellIdentifier = @"itemCardCell";
        ItemCardCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Set up the content size of the scroll view
        [self setScrollViewSize:cell.scrollView withPages:_item.images.count];
        cell.pageControl.numberOfPages =_item.images.count;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //load images for scrollview
        for (NSInteger i=0; i<_item.images.count; i++) {
            [self loadPage:i forScrollView:cell.scrollView];
        }
        //
        cell.nameLabel.text = _item.title;
        
        NSString *price =_item.priceNew.length >2 ? _item.priceNew : _item.price;
        cell.priceLabel.text =  [NSString stringWithFormat:@"Цена: %@ Руб.",price];
        cell.weightLabel.text = [NSString stringWithFormat:@"Вес: %@ грамм",_item.weight];
        NSString *itemDescription =[_item.desc stringByReplacingOccurrencesOfString:@"<br>" withString:@"//n"];
        itemDescription = [itemDescription stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        //
        cell.textView.text = itemDescription;
        
        return cell;
    }
    
    if (indexPath.row == 1) {
        NSLog(@"item have review!");
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
        cell.textLabel.text = [NSString stringWithFormat:@"Обзор %@",_item.title];
        return cell;
    }
    //should be never happen
    UITableViewCell*cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    return cell;;
}

@end
