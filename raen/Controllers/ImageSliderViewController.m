//
//  ImageSliderViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 03.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ImageSliderViewController.h"
#import "ImageModel.h"
#import "UIImageView+WebCache.h"

@interface ImageSliderViewController () <UIScrollViewDelegate>

@end

@implementation ImageSliderViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView setDelegate:self];
	// Do any additional setup after loading the view.
    [self setBottomToolbarLabelTextByCurrentImageNbr];
    [self.bottomToolbarView.layer setCornerRadius:5.0];
    [self setScrollViewSize:self.scrollView withPages:_images.count];
    for (NSInteger i=0; i<_images.count; i++) {
        [self loadPage:i forScrollView:self.scrollView withSpinner:nil];
    }
    [self scrollToCurrentImageNmbr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)setBottomToolbarLabelTextByCurrentImageNbr{
    self.bottonToolbarLabel.text = [NSString stringWithFormat:@"%d из %d",self.currentImageNmr+1,_images.count];
}
#pragma mark - ScrollView methods
-(void)scrollToCurrentImageNmbr{
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.currentImageNmr;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
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
    ImageModel *image = _images[page];
    
    [imageView setImageWithURL:[NSURL URLWithString:image.big] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [spinner stopAnimating];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }];
    
    
}

#pragma mark - UIScrollView Delegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //we have to get current page number for toolbar Label
    CGFloat pageWidth = self.scrollView.frame.size.width;
    self.currentImageNmr = (NSInteger)floor((self.scrollView.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    [self setBottomToolbarLabelTextByCurrentImageNbr];
}

@end
