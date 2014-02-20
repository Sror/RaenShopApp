//
//  BrowserViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 17.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserViewController : UIViewController  <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic,strong) NSString *link;
@property (weak,nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end
