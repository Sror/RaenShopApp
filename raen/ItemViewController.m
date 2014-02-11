//
//  ItemViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ItemViewController.h"
#import "HUD.h"
#import "JSONModelLib.h"
#import "ItemModel.h"
#import "ImageModel.h"

#import "UIImageView+WebCache.h"

#define kRaenItemLink @"http://raenshop.ru/api/catalog/goods/id/"

@interface ItemViewController () {
    ItemModel *item;
}

@end

@implementation ItemViewController
@synthesize  pageControl = _pageControl;
@synthesize  scrollView = _scrollView;


-(void)viewDidAppear:(BOOL)animated{
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
    [self.scrollView setDelegate:self];
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
                self.itemName.text = item.title;
            } else {
                [HUD showAlertWithTitle:@"Error" text:@"Sorry, invalid JSON data"];
            }
        });
        
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIScrollViewDelegate

@end
