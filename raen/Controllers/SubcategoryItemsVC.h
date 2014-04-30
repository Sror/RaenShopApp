//
//  SubcategoryItemsVC.h
//  raenapp
//
//  Created by Alexey Ivanov on 30.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface SubcategoryItemsVC : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSString *subcategoryID;
@property (nonatomic,strong) UIRefreshControl *refreshControl;

@end
