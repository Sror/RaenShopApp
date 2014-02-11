//
//  WebViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 06.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)loadCookies{
    NSDictionary* cookieDictionary = [[NSUserDefaults standardUserDefaults] dictionaryForKey:@"cookie_key"];
    NSDictionary* cookieProperties = [cookieDictionary valueForKey:@".raenshop.ru"];
    if (cookieProperties != nil) {
        NSHTTPCookie* cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        NSArray* cookieArray = [NSArray arrayWithObject:cookie];
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookieArray forURL:[NSURL URLWithString:@".raenshop.ru"] mainDocumentURL:nil];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self loadCookies];
    NSLog(@"webViewController viewdidload");
    NSURL *url =[NSURL URLWithString:@"http://raenshop.ru/"];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    
    [self.webView loadRequest:urlRequest];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(id)sender {
    [self.textField resignFirstResponder];
    NSURL *url = [NSURL URLWithString:self.textField.text];
    NSURLRequest *urlRequest =[NSURLRequest requestWithURL:url];
    [self.webView loadRequest:urlRequest];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (NSHTTPCookie *eachCookie in cookieStorage.cookies) {
        if ([eachCookie.domain isEqualToString:@"raenshop.ru"]||[eachCookie.domain isEqualToString:@".raenshop.ru"] ) {
            NSLog(@"COOOOOOKIIIEE in webView \n%@",eachCookie);
        }
    }
}
@end
