//
//  OrderCell.h
//  raenapp
//
//  Created by Alexey Ivanov on 18.04.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *numberAndDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
