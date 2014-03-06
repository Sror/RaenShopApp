//
//  TVCell.h
//  raenapp
//
//  Created by Alexey Ivanov on 13.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IndexedCV.h"

static NSString *CollectionViewCellIdentifier = @"cvCell";

@interface TVCell : UITableViewCell

@property (strong, nonatomic) IBOutlet IndexedCV *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
