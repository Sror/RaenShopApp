//
//  GridItemsVC.m
//  raenapp
//
//  Created by Alexey Ivanov on 30.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "GridItemsVC.h"
#import "ItemCell.h"
#import "HUD.h"
#import "GoodModel.h"
#import "UIImageView+WebCache.h"
#import "ItemCardViewController.h"

#define kRaenApiItemsLink @"http://raenshop.ru/api/catalog/goods_list/cat_id/"

@interface GridItemsVC (){
    NSArray *_items;
}

@end

@implementation GridItemsVC

-(void)viewDidAppear:(BOOL)animated{
    [HUD showUIBlockingIndicatorWithText:@"Fetching JSON"];
    NSLog(@"viewDidAppear");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //code executed in the background
        //2
        NSLog(@"subcategory %@",self.subcategory);
        if (!self.subcategory.id.length>0) {
            NSLog(@"error:categoryId is nil!");
            return ;
        }
        
       
        NSString *fullUrl = [kRaenApiItemsLink stringByAppendingString:self.subcategory.id];
        NSLog(@"fullUrl %@",fullUrl);
        NSData* itemsData = [NSData dataWithContentsOfURL:
                            [NSURL URLWithString:fullUrl]
                            ];
        //3
        NSDictionary* itemsJson = [NSJSONSerialization
                                  JSONObjectWithData:itemsData
                                  options:kNilOptions
                                  error:nil];
        //4
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error;
            _items = [GoodModel arrayOfModelsFromDictionaries:itemsJson[@"goods"]];
            if (error) {
                NSLog(@"ItemModel initWithDictionary error %@",error.localizedDescription);
            }
            [HUD hideUIBlockingIndicator];
            if (_items) {
                
                [self.collectionView reloadData];
            } else {
                [HUD showAlertWithTitle:@"Error" text:@"Sorry, invalid JSON data"];
            }
        });
        
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
    NSLog(@"subcategory.title %@",self.subcategory.title);
    self.navigationItem.title = self.subcategory.title;
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UICollectionViewDataSource
#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
};

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CollectionViewCellIdentifier = @"itemCell";
    ItemCell *itemCell = (ItemCell*)[collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    GoodModel *item = _items[indexPath.row];
    itemCell.titleLabel.text = item.title;
    [itemCell.activityIndicator startAnimating];
    if (![item.priceNew isEqualToString:@"0"]) {
        itemCell.priceNewLabel.text = [NSString stringWithFormat:@"%@ руб.",item.priceNew];
        itemCell.priceLabel.text = [NSString stringWithFormat:@"Было %@ руб.",item.price];
    }else{
        itemCell.priceNewLabel.backgroundColor = [UIColor colorWithRed:255/255.0 green:204/255.0 blue:102/255.0 alpha:1.0];
        itemCell.priceNewLabel.text = [NSString stringWithFormat:@"%@ руб.",item.price];
        [itemCell.priceLabel setHidden:YES];
    }
    [itemCell.imageView setImageWithURL:[NSURL URLWithString:item.imageLink] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
        [itemCell.activityIndicator stopAnimating];
        if (error) {
            NSLog(@"error to download image for item %@",item.title);
        }
    }];
    return itemCell;
}
#pragma  mark -UiCollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GoodModel *item = _items[indexPath.row];
    [self performSegueWithIdentifier:@"toItemCardView" sender:item.id];
}
#pragma mark - 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toItemCardView"]) {
        ItemCardViewController *itemCardVC =[segue destinationViewController];
        itemCardVC.itemID = sender;
    }
}

@end
