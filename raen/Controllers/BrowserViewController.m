//
//  BrowserViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 17.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@end

@implementation BrowserViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    
    if (!self.link) {
        NSLog(@"empty link for browser!");
    }
    if ([self.link rangeOfString:@"iframe"].location !=NSNotFound) {
        NSLog(@"iframe found!");
        NSString *HTMLstring =[NSString stringWithFormat:@"<html><body><center><div style=\"width: 835px; margin: 0 auto;\">%@</div></center></body></html>",self.link];
        [self.webView loadHTMLString:HTMLstring baseURL:nil];
        
    }
    if (self.link) {
        NSURL *url =[NSURL URLWithString:self.link];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)webViewDidStartLoad:(UIWebView *)webView{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [self.spinner startAnimating];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{

    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
    [self.spinner stopAnimating];
}
@end
