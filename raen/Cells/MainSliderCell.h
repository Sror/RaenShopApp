//
//  MainSliderCell.h
//  raenapp
//
//  Created by Alexey Ivanov on 03.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainSliderCell : UITableViewCell <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

- (IBAction)pageChanged:(id)sender;



@end
