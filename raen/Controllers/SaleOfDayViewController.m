//
//  SaleOfDayViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "SaleOfDayViewController.h"
#import "RaenAPICommunicator.h"
#import "UIImageView+WebCache.h"
#import "ItemCardViewController.h"
#import "SaleOfDayModel.h"
#import "SaleOfDayDescriptionModel.h"
#import "MBProgressHUD.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@interface SaleOfDayViewController  () <RaenAPICommunicatorDelegate,UITextViewDelegate>{
    RaenAPICommunicator* _communicator;
}

@end

@implementation SaleOfDayViewController


-(void)viewDidAppear:(BOOL)animated{
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Sale of day Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    
    [_communicator getSaleOfDay];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.textView setDataDetectorTypes:UIDataDetectorTypeLink];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - RaenAPICommunicatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Проверьте подключение к интернету" delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}
-(void)didReceiveSaleOfDay:(id)saleOfDayModel{
    NSLog(@"didReceiveSaleOfDay");
    SaleOfDayModel *saleOfDay = (SaleOfDayModel*)saleOfDayModel;
    
    //set image in imageView
    if (saleOfDay.image) {
        [self.spinner startAnimating];
        __weak typeof(self) weakSelf = self;
        [self.imageView setImageWithURL:[NSURL URLWithString:saleOfDay.image] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            typeof(self) strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf.spinner stopAnimating];
            }
        }];
    }else{
        NSLog(@"--- NO IMAGE For Sale of day");
    }
    
    [self.textView setAttributedText:[self attributedStringFromDescriptions:saleOfDay.descriptions]];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
}
#pragma mark - Helpers
-(NSAttributedString*)attributedStringFromDescriptions:(NSArray*)descriptions{
    NSMutableAttributedString *fullAttrString = [[NSMutableAttributedString alloc] init];

    for (SaleOfDayDescriptionModel *description in descriptions) {
        if (description.text.length>0) {
            NSAttributedString *tmpAttString = [[NSAttributedString alloc] init];
            if (![description.id isEqualToString:@"0"]) {
               tmpAttString = [tmpAttString initWithString:description.text
                                                attributes:@{NSLinkAttributeName: description.id,
                                                            }];
            }else{
                tmpAttString = [tmpAttString initWithString:description.text];
            }
            [fullAttrString appendAttributedString:tmpAttString];
        }
    }
    return fullAttrString;
}
#pragma mark - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange{
    NSLog(@"textView should interactWith URL %@",URL);
    if ([[URL absoluteString] rangeOfString:@"http://"].location == NSNotFound) {
        [self performSegueWithIdentifier:@"toItemCardView" sender:[URL absoluteString]];
    }
    return YES;
}

#pragma mark -
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toItemCardView"]) {
        ItemCardViewController *itemCardVC=segue.destinationViewController;
        itemCardVC.itemID = sender;
    }
}

@end
