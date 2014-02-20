//
//  AvailableItemCell.m
//  raenapp
//
//  Created by Alexey Ivanov on 19.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "AvailableItemCell.h"

@implementation AvailableItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addToCartButtonPressed:(id)sender {
}
@end
