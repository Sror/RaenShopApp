//
//  ImageSliderViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 03.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageSliderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bottomToolbarView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *bottonToolbarLabel;
@property (nonatomic,strong) NSArray* images;
@property (nonatomic,assign) NSInteger currentImageNmr;

- (IBAction)doneButtonPressed:(id)sender;

@end
