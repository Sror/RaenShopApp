//
//  ItemCell.m
//  raenapp
//
//  Created by Alexey Ivanov on 30.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(UIView *)selectedBackgroundView{
    UIView *backgroundView  = [[UIView alloc] initWithFrame:self.frame];
    backgroundView.backgroundColor  = [UIColor lightGrayColor];
    return backgroundView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
