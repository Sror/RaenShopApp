//
//  BrowserViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 17.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "BrowserViewController.h"

@interface BrowserViewController ()<UIActionSheetDelegate>


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
        NSLog(@"HTMLString %@",HTMLstring);
        [self.webView loadHTMLString:HTMLstring baseURL:nil];
        
    }
    if (self.link) {
        NSLog(@"browser link %@",self.link);
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
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self.navigationItem setTitle:theTitle];
    [self.spinner stopAnimating];
}

#pragma mark - IBActions
- (IBAction)shareButtonPressed:(id)sender {
    NSLog(@"shareButtonPressed");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:self.link delegate:self cancelButtonTitle:@"Отмена" destructiveButtonTitle:@"Открыть в Safari" otherButtonTitles:@"Скопировать ссылку", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)closeBrowserButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIActionSheetDelegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.link]];
    }
    if (buttonIndex==1){
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = self.link;
    }
}

@end
