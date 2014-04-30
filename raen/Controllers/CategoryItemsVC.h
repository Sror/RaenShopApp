//
//  CategoryItemsGridViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 08.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryModel.h"

@interface CategoryItemsVC : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic,strong) NSString *currentCategoryId;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) UIRefreshControl* refreshControl;
@end
