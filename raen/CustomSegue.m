//
//  CustomSegue.m
//  raenapp
//
//  Created by Alexey Ivanov on 24.01.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "CustomSegue.h"

@implementation CustomSegue
- (void) perform{
    // Получаем экраны, с которыми будем работать
    UIViewController *src = (UIViewController *) self.sourceViewController;
    UIViewController *dst = (UIViewController *) self.destinationViewController;
    
    // Осуществляем простой переход
    [UIView transitionFromView:src.view
                        toView:dst.view
                      duration:1
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    completion:nil];
    
    // Осуществляем переход для Navigation Controller'a
    [UIView transitionFromView:src.navigationItem.titleView
                        toView:dst.navigationItem.titleView
                      duration:1
                       options:UIViewAnimationOptionTransitionNone
                    completion:nil];
    
    // Добавляем Push нашей Segue
    [src.navigationController pushViewController:dst animated:NO];
}
@end
