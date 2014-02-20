//
//  AvailableItemCell.h
//  raenapp
//
//  Created by Alexey Ivanov on 19.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AvailableItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *thumbnail;
@property (weak, nonatomic) IBOutlet UIButton *addToCartButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UITextView *textView;

- (IBAction)addToCartButtonPressed:(id)sender;

@end
