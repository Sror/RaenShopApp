//
//  ItemViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

//controllers
#import "ItemCardViewController.h"
#import "BrowserViewController.h"
#import "RaenAPICommunicator.h"
//models
#import "JSONModelLib.h"
#import "ItemModel.h"
#import "ImageModel.h"
#import "SpecItem.h"
//views
#import "ItemCardCell.h"
#import "AvailableItemCell.h"
#import "UIImageView+WebCache.h"
#import "HUD.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ItemCardViewController ()<RaenAPICommunicatorDelegate> {
    
    ItemModel *_item;
    NSMutableArray *_properties;
    RaenAPICommunicator *_communicator;
}
@property (nonatomic,strong) NSMutableArray *properties;
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
    [HUD hideUIBlockingIndicator];
    _item = itemCard;
    self.navigationItem.title = _item.title;
    [self addReviewAndVideo];
    [self.tableView setHidden:NO];
    [self.tableView reloadData];
}

-(void)didAddItemToCartWithResponse:(NSDictionary *)response{
    NSLog(@"succesful did add item to cart with response %@",response);
    NSString *totalItems=response[@"total_items"];
    NSLog(@"setting tabbar badge");
    
    [[[[[self tabBarController]tabBar]items]objectAtIndex:2] setBadgeValue:[NSString stringWithFormat:@"%@",totalItems]];
    [_communicator saveCookies];
    
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [imageView setImageWithURL:[NSURL URLWithString:image.big] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [activityIndicator stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }];
}


-(void)setScrollViewSize:(UIScrollView*)scrollview withPages:(NSInteger)pages {
    CGSize pagesScrollViewSize = scrollview.frame.size;
    scrollview.contentSize = CGSizeMake(pagesScrollViewSize.width *pages, pagesScrollViewSize.height);
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else if(section==1){
        return _properties.count;
    }else{
        return [self availabledSpecItems].count;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //set height for first tableview cell
    if (indexPath.section==0) {
        UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        NSString *itemDescription =[_item.desc stringByReplacingOccurrencesOfString:@"<br>" withString:@"//n"];
        itemDescription = [itemDescription stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        itemDescription = [itemDescription stringByAppendingString:[NSString stringWithFormat:@"\nВес: %@ гр.",_item.weight]];
        
        CGRect boundingRect = [itemDescription boundingRectWithSize:CGSizeMake(268, 4000)
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:font}
                                             context:nil];
        
        CGSize boundingSize = boundingRect.size;
        // end ios7 only
        return (183+20+boundingSize.height);

    }
    if (indexPath.section==2) {
        UIFont *font =[UIFont fontWithName:@"HelveticaNeue" size:14];
        SpecItem *specItem = [self availabledSpecItems][indexPath.row];
        NSString *paramStr =[self allParamsToStrFrom:specItem];
        paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"\nЦвет: %@",specItem.color]];
        CGRect boundingRect = [paramStr boundingRectWithSize:CGSizeMake(125, 4000)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:font}
                                                      context:nil];
        CGSize boundingSize = boundingRect.size;
        NSLog(@"boundingSize.height %f, weight %f",boundingSize.height,boundingSize.width);
        if (boundingSize.height<75) {
            return 80;
        }else{
            NSLog(@"cell size %f",10+boundingSize.height);
            return (10+boundingSize.height);
        }
        
        
        //return 70;
    }
    //all other cells height =44px
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section == 0) {
        //item card cell
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
        //TITLE
        cell.nameLabel.text = _item.title;
        //PRICE LABELS
        if (_item.priceNew.length>2) {
            cell.priceLabel.text =  [NSString stringWithFormat:@"%@ Руб.",_item.priceNew];
            cell.oldPriceLabel.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@ Руб.",_item.price]
                                                                      attributes:@{NSStrikethroughStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle]}];
        }else{
            cell.priceLabel.text = @"";
            cell.oldPriceLabel.text = [NSString stringWithFormat:@"%@ Руб.",_item.price];
        }
        //DESCRIPTION
        NSString *itemDescription =[_item.desc stringByReplacingOccurrencesOfString:@"<br>" withString:@"//n"];
        itemDescription = [itemDescription stringByReplacingOccurrencesOfString:@"<br />" withString:@""];
        itemDescription = [itemDescription stringByAppendingString:[NSString stringWithFormat:@"\nВес: %@ гр.",_item.weight]];
        cell.textView.text = itemDescription;
        return cell;
    }
    //VIDEO AND REVIEW LINKS section
    if (indexPath.section == 1) {
        NSDictionary *tmpDict =_properties[indexPath.row];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell" forIndexPath:indexPath];
        cell.textLabel.text = [tmpDict allKeys][0];
        return cell;
    }
    //availabled items section
    if (indexPath.section==2) {
        SpecItem *specItem = [self availabledSpecItems][indexPath.row];
        AvailableItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"availableItemCell" forIndexPath:indexPath];
        NSString *paramStr =[self allParamsToStrFrom:specItem];
        paramStr = [paramStr stringByAppendingString:[NSString stringWithFormat:@"\nЦвет: %@",specItem.color]];
        cell.textView.text = paramStr;
        [cell.addToCartButton setTag:indexPath.row];
        [cell.addToCartButton addTarget:self action:@selector(buyButtonPressed:)
                       forControlEvents:UIControlEventTouchUpInside];
        if ([specItem.image rangeOfString:@"http"].location !=NSNotFound) {
            [cell.spinner startAnimating];
            [cell.thumbnail setImageWithURL:[NSURL URLWithString:specItem.image]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                      [cell.spinner stopAnimating];
                                      if (!error) {
                                         
                                      }else{
                                          NSLog(@"error to load image");
                                          [cell.thumbnail setImage:[UIImage imageNamed:@"no_image.jpg"]];
                                      }
                                  }];
        }else{
            NSLog(@"No image for thumbnail image");
            [cell.thumbnail setImage:[UIImage imageNamed:@"no_image.jpg"]];
        }
        return cell;
    }
    //should never happen
    NSLog(@"----should never happen----");
    UITableViewCell *cell =[self.tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    cell.textLabel.text = @"empty cell";
    return cell;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==1 &&_properties.count) {
        return @"Подробнее:";
    }
    if (section==2 &&_item.specItems.count) {
        return @"Модели и наличие:";
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
        NSDictionary *tmpDict =_properties[indexPath.row];
        [self performSegueWithIdentifier:@"toBrowser" sender:tmpDict];
    }
}
#pragma mark - prepare for segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
#warning WTF?
    if ([segue.identifier isEqualToString:@"toBrowser"]) {
        BrowserViewController *browserVC= segue.destinationViewController;
        NSDictionary *tmpDict = sender;
        browserVC.navigationItem.title = [tmpDict allKeys][0];
        browserVC.link = [tmpDict allValues][0];
    }
}
#pragma mark - buy button pressed
-(void)buyButtonPressed:(id)sender{
    NSInteger row = [sender tag];
    NSLog(@"buyButtonPressed row %ld",(long)row);
    //to do animation
    [self animateCellWithRow:row];
    [_communicator addItemToCart:_item withSpecItemAtIndex:row andQty:1];
}
#pragma mark - Helpers
-(void)animateCellWithRow:(NSInteger)row{
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:row inSection:2];
    AvailableItemCell *cell =(AvailableItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imgView =cell.thumbnail;
    CGRect rect =[imgView.superview convertRect:imgView.frame fromView:nil];
    rect = CGRectMake(rect.origin.x+35, (rect.origin.y*-1)+35, imgView.frame.size.width, imgView.frame.size.height);
	NSLog(@"rect is %f,%f,%f,%f",rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    // create new duplicate image
	UIImageView *starView = [[UIImageView alloc] initWithImage:imgView.image];
    [starView setFrame:rect];
    //do i need this?
    
	starView.layer.cornerRadius=5;
	starView.layer.borderColor=[[UIColor blackColor] CGColor];
	starView.layer.borderWidth=1;
    
    [self.view addSubview:starView];
    // begin ---- apply position animation
	CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    pathAnimation.duration=0.8;
	pathAnimation.delegate=self;
	
	// tab-bar right side item frame-point = end point
	CGPoint endPoint = CGPointMake(320 , 480);
    if (IS_IPHONE_5)
    {
        endPoint = CGPointMake(265, 550);
    }else{
        endPoint = CGPointMake(265, 440);
    }
    NSLog(@"endpoint.x %f , endpoint.y %f",endPoint.x,endPoint.y);
	CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, starView.frame.origin.x, starView.frame.origin.y);
    CGPathAddCurveToPoint(curvedPath, NULL, endPoint.x, starView.frame.origin.y, endPoint.x, starView.frame.origin.y, endPoint.x, endPoint.y);
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
	// end ---- apply position animation
	
	// apply transform animation
	CABasicAnimation *basic=[CABasicAnimation animationWithKeyPath:@"transform"];
	[basic setToValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.25, 0.25, 0.25)]];
	[basic setAutoreverses:NO];
	[basic setDuration:0.8];
	
	[starView.layer addAnimation:pathAnimation forKey:@"curveAnimation"];
	[starView.layer addAnimation:basic forKey:@"transform"];
	
	[starView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.8];
    
}
-(void)addReviewAndVideo{
    _properties =[NSMutableArray array];
    if ([_item.review rangeOfString:@"http"].location != NSNotFound) {
        NSLog(@"item review found");
        NSString* itemPropertyKey =[NSString stringWithFormat:@"Обзор %@",_item.title];
        NSDictionary *tmpDict =@{itemPropertyKey: _item.review};
        [_properties addObject:tmpDict];
    }
    if ([_item.video rangeOfString:@"http"].location !=NSNotFound) {
        NSLog(@"item video link found");
        NSString* itemPropertyKey =[NSString stringWithFormat:@"Видеообзор %@",_item.title];
        NSDictionary *tmpDict =@{itemPropertyKey: _item.video};
        [_properties addObject:tmpDict];
    }
}
-(NSString*)allParamsToStrFrom:(SpecItem*)specItem{
    NSArray *params = @[specItem.param1,specItem.param2,specItem.param3,specItem.param4,specItem.param5];
    NSMutableArray *availableParameters =[NSMutableArray array];
    for (NSString*parameter in params) {
        if (![parameter isEqualToString:@"0"]) {
            [availableParameters addObject:parameter];
        }
    }
    NSString *param = @"";
    for (int i=0; i<availableParameters.count; i++)
    {
        NSString *currentParameter = availableParameters[i];
        if (i==0) {
            param = currentParameter;
        }else{
            param = [param stringByAppendingString:[NSString stringWithFormat:@"\n%@",currentParameter]];
        }
    }
    return param;
}
-(NSArray*)availabledSpecItems{
    NSMutableArray *availabledSpecItems = [NSMutableArray array];
    for (SpecItem *specItem in _item.specItems) {
        if (specItem.sklad.integerValue>0 || specItem.piter.integerValue>0 || specItem.shop.integerValue>0) {
            [availabledSpecItems addObject:specItem];
        }
    }
    return availabledSpecItems;
}
@end
