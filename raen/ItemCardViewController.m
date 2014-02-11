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

#define kRaenItemLink @"http://raenshop.ru/api/catalog/goods/id/"

@interface ItemCardViewController () {
    ItemModel *item;
    NSMutableArray *imageViews;
}

@end

@implementation ItemCardViewController


-(void)viewDidAppear:(BOOL)animated{
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
    //1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code executed in the background
        //2
        NSString *fullUrl = [kRaenItemLink stringByAppendingString:self.itemID];
        NSLog(@"fullUrl %@",fullUrl);
        NSData* itemData = [NSData dataWithContentsOfURL:
                             [NSURL URLWithString:fullUrl]
                             ];
        //3
        NSDictionary* itemJson = [NSJSONSerialization
                                   JSONObjectWithData:itemData
                                   options:kNilOptions
                                   error:nil];
        //4
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            item = [[ItemModel alloc] initWithDictionary:itemJson error:&error];
            if (error) {
                NSLog(@"ItemModel initWithDictionary error %@",error.localizedDescription);
            }
            [HUD hideUIBlockingIndicator];
            if (item) {
               // NSLog(@"item %@",item);
                self.navigationItem.title = item.title;
                [self.tableView setHidden:NO];
                [self.tableView reloadData];
            } else {
                [HUD showAlertWithTitle:@"Error" text:@"Sorry, invalid JSON data"];
            }
        });
        
    });
}
-(void)loadPage:(NSInteger)page forScrollView:(UIScrollView*)scrollView {
    NSLog(@"loadPage %i",page);
    CGRect frame = scrollView.bounds;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0.0f;
    UIImageView *imageView =[[UIImageView alloc] initWithFrame:frame];
    //NSLog(@"current imageView frame x=%f , y=%f",frame.origin.x,frame.origin.y);
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [scrollView addSubview:imageView];
    ImageModel *image = item.images[page];
    [imageView setImageWithURL:[NSURL URLWithString:image.big] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        //  [self.view reloadInputViews];
        
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView setHidden:YES];
   	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setScrollViewSize:(UIScrollView*)scrollview withPages:(NSInteger)pages {
    CGSize pagesScrollViewSize = scrollview.frame.size;
    scrollview.contentSize = CGSizeMake(pagesScrollViewSize.width *pages, pagesScrollViewSize.height);
    
}
#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row==0) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        
        NSString *itemDescription =[item.desc stringByReplacingOccurrencesOfString:@"<br>" withString:@"//n"];
        itemDescription = [itemDescription stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        
        
        //CGSize aboutSize = [itemDescription sizeWithFont:font constrainedToSize:CGSizeMake(268, 4000)];
        
        // if deployment target is iOS7 and you want to get rid of the warning above
        // comment the line above and uncomment the following section
        
        // ios 7 only
        CGRect boundingRect = [itemDescription boundingRectWithSize:CGSizeMake(268, 4000)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:font}
                                             context:nil];
        
        CGSize boundingSize = boundingRect.size;
        // end ios7 only
        
        
        return (243+50+boundingSize.height);
    }
    return 44;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"itemCardCell";
    ItemCardCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Set up the content size of the scroll view
    [self setScrollViewSize:cell.scrollView withPages:item.images.count];
    cell.pageControl.numberOfPages = item.images.count;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (cell == nil) {
        ItemCardCell *cell =[[ItemCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    //load images for scrollview
    for (NSInteger i=0; i<item.images.count; i++) {
        [self loadPage:i forScrollView:cell.scrollView];
    }
    cell.nameLabel.text = item.title;
    NSString *price =item.priceNew.length >0 ? item.priceNew :item.price;
    cell.priceLabel.text =  [NSString stringWithFormat:@"%@ Руб.",price];
    cell.weightLabel.text = item.weight;
    NSString *itemDescription =[item.desc stringByReplacingOccurrencesOfString:@"<br>" withString:@"//n"];
    itemDescription = [itemDescription stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
    //
    
    
    cell.textView.text = itemDescription;
    return cell;
}

@end
