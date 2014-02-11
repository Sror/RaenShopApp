//
//  GridItemsVC.h
//  raenapp
//
//  Created by Alexey Ivanov on 30.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChildrenModel.h"

@interface GridItemsVC : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong,nonatomic) ChildrenModel *subcategory;
@end
