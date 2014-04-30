//
//  ItemViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

//controllers
#import "ItemCardViewController.h"
#import "RaenAPICommunicator.h"
#import "MWPhotoBrowser.h"
#import "TOWebViewController.h"

//models
#import "JSONModelLib.h"
#import "ItemModel.h"
#import "ImageModel.h"
#import "SpecItem.h"
//views
#import "ItemCardCell.h"
#import "AvailableItemCell.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

@interface ItemCardViewController ()<RaenAPICommunicatorDelegate,MWPhotoBrowserDelegate> {
    RaenAPICommunicator *_communicator;
    ItemModel *_item;
    NSMutableArray *_properties;
}
@property (nonatomic,strong) NSMutableArray *properties;
@end

@implementation ItemCardViewController

-(void)viewDidAppear:(BOOL)animated
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Item card Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
   
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    
    [self.tableView setHidden:YES];
    [self setupRefreshControl];
    if (self.itemID) {
        [self performSelectorOnMainThread:@selector(refreshView:) withObject:nil waitUntilDone:YES];
    }

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RefreshControl
-(void)setupRefreshControl{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)refreshView:(UIRefreshControl *)sender {
    _item = nil;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_communicator getItemCardWithId:self.itemID];
}

#pragma mark - RaenAPICommunicatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [self.refreshControl endRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alert show];
}

-(void)didReceiveItemCard:(id)itemCard{
    _item = (ItemModel*) itemCard;
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.navigationItem.title = _item.title;
    [self addReviewAndVideo];
    
    [self.tableView reloadData];
    [self.tableView setHidden:NO];
    [self.refreshControl endRefreshing];
}
#pragma mark - add item to cart
-(void)didAddItemToCartWithResponse:(NSDictionary *)response{
    NSLog(@"succesful did add item to cart");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSString *totalItems=response[@"total_items"];
    
    NSLog(@"setting tabbar badge");
    [self.tabBarController.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%@",totalItems]];
    [_communicator saveCookies];
    
}
-(void)didFailureAddingItemToCartWithError:(JSONModelError *)error{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:error.description delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
#pragma  mark - ScrollView
-(void)setImagesInScrollview:(UIScrollView*)scrollview{
    //set new images
    for (int i=0;i<_item.images.count;i++) {
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
        ImageModel *image = _item.images[i];
        [imageView setImageWithURL:[NSURL URLWithString:image.big]
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

-(NSArray*)photoBrowserPhotos{
    NSMutableArray *photos = [NSMutableArray array];
    for (ImageModel* image in _item.images) {
        [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:image.big]]];
    }
    return photos;
}

-(void)handleSlideTap:(UITapGestureRecognizer*)tapGestureRecognizer{
    NSInteger imageTag = tapGestureRecognizer.view.tag;

    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    [self setupPhotoBrowser:photoBrowser withCurrentPhotoIndex:imageTag];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:photoBrowser] animated:YES completion:nil];
    //[self.navigationController pushViewController:photoBrowser animated:YES];
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
    NSLog(@"heightForRowAtIndexPath section %i , row %i",indexPath.section,indexPath.row);
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
        if (boundingSize.height<75) {
            return 80;
        }else{
           
            return (10+boundingSize.height);
        }
    }
    //all other cells height =44px
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"cellForRowAtIndexPath section %i row %i",indexPath.section, indexPath.row);
    //Photo slider
    if (indexPath.section == 0) {
        //item card cell
        static NSString *CellIdentifier = @"itemCardCell";
        ItemCardCell *cell =[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        // Set up the content size of the scroll view
        [self setScrollViewSize:cell.scrollView withPages:_item.images.count];
        cell.pageControl.numberOfPages =_item.images.count;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //load images for scrollview
        [self setImagesInScrollview:cell.scrollView];

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
            cell.thumbnail.tag = indexPath.row;
            cell.thumbnail.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnThumbnail:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [cell.thumbnail addGestureRecognizer:tap];
           
            [cell.thumbnail setImageWithURL:[NSURL URLWithString:specItem.image]
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                                      [cell.spinner stopAnimating];
                                      if (!error) {
                                         
                                      }else{
                                          NSLog(@"error to load image");
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
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    cell.textLabel.text = @"empty cell";
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==1 &&_properties.count) {
        return @"Подробнее:";
    }
    if (section==2 &&_item.specItems.count) {
        return @"Модели в наличие:";
    }
    return nil;
}

#pragma mark -
#pragma mark UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==1) {
        NSDictionary *tmpDict =_properties[indexPath.row];
        NSString *rawstring = [tmpDict allValues][0];
        NSURL *url = [[NSURL alloc] init];
        TOWebViewController *webBrowser = [[TOWebViewController alloc] init];
        if ([rawstring rangeOfString:@"iframe"].location !=NSNotFound) {
            NSLog(@"IFRAME FOUND");
            NSString *htmlString = [NSString stringWithFormat:@"<html><body><center><div style=\"width: 835px; margin: 0 auto;\">%@</div></center></body></html>",rawstring];
            webBrowser.HTMLString = htmlString;
            
        }
        if ([rawstring rangeOfString:@"http"].location != NSNotFound) {
            url = [NSURL URLWithString:rawstring];
            webBrowser.url = url;
        }
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:webBrowser] animated:YES completion:nil];
//        [webBrowser setHidesBottomBarWhenPushed:YES];
//        [self.navigationController pushViewController:webBrowser animated:YES];
    }
}
#pragma mark - prepare for segue
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"prepareForSegue %@",segue.identifier);
    
}

#pragma mark - buy button pressed
-(void)buyButtonPressed:(id)sender{
    NSInteger row = [sender tag];
    //to do animation
    [self animateCellWithRow:row];
    [_communicator addItemToCart:_item withSpecItemAtIndex:row andQty:1];
}
#pragma mark - Cell animation
-(void)animateCellWithRow:(NSInteger)row{
    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:row inSection:2];
    AvailableItemCell *cell =(AvailableItemCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imgView =cell.thumbnail;
    CGRect rect =[imgView.superview convertRect:imgView.frame fromView:nil];
    rect = CGRectMake(rect.origin.x+35, (rect.origin.y*-1)+35, imgView.frame.size.width, imgView.frame.size.height);
    // create new duplicate image
	UIImageView *starView = [[UIImageView alloc] initWithImage:imgView.image];
    [starView setFrame:rect];
    
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
	CGPoint endPoint = CGPointZero;
    if (IS_IPHONE_5)
    {
        endPoint = CGPointMake(275, 550);
    }else{
        endPoint = CGPointMake(275, 440);
    }
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
	
	[starView performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.75];
    
}
#pragma mark - Helpers
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


#pragma mark - MWPhotoBrowser methods

-(void)setupPhotoBrowser:(MWPhotoBrowser*)photoBrowser withCurrentPhotoIndex:(NSInteger)index{
    // Set options
    photoBrowser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    photoBrowser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    photoBrowser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    photoBrowser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    photoBrowser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    photoBrowser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    
    [photoBrowser showNextPhotoAnimated:YES];
    [photoBrowser showPreviousPhotoAnimated:YES];
    
    [photoBrowser setCurrentPhotoIndex:index];
}

-(void)tappedOnThumbnail:(UITapGestureRecognizer*)gestureRecognizer{
    NSInteger tag = gestureRecognizer.view.tag;
    NSLog(@"tapped on thumbnail %i",tag);
    MWPhotoBrowser *photoBrowser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    [self setupPhotoBrowser:photoBrowser withCurrentPhotoIndex:0];
    [self presentViewController:[[UINavigationController alloc] initWithRootViewController:photoBrowser] animated:YES completion:nil];
    //[self.navigationController pushViewController:photoBrowser animated:YES];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return [self photoBrowserPhotos].count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index<[self photoBrowserPhotos].count) {
        return [[self photoBrowserPhotos] objectAtIndex:index];
    }
    return nil;
}
@end
