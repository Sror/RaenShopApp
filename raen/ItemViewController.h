//
//  ItemViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemViewController : UIViewController <UIScrollViewDelegate>
@property (nonatomic,strong) NSString *itemID;
@property (weak,nonatomic) IBOutlet UILabel *itemName;
@property (weak,nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak,nonatomic) IBOutlet UIScrollView *scrollView;

@end
