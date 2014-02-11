//
//  WebViewController.h
//  raenapp
//
//  Created by Alexey Ivanov on 06.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

- (IBAction)buttonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *button;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (nonatomic,weak) IBOutlet UIWebView *webView;
@end
