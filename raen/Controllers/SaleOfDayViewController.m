//
//  SaleOfDayViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 04.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "SaleOfDayViewController.h"
#import "RaenAPICommunicator.h"
#import "HUD.h"
#import "UIImageView+WebCache.h"

#import "SaleOfDayModel.h"
#import "SaleOfDayDescriptionModel.h"

@interface SaleOfDayViewController  () <RaenAPICommunicatorDelegate>{
    RaenAPICommunicator *_communicator;
}

@end

@implementation SaleOfDayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    [_communicator getSaleOfDay];
    [HUD showUIBlockingIndicator];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - RaenAPICommunicatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    [HUD hideUIBlockingIndicator];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil];
    [alert show];
}
-(void)didReceiveSaleOfDay:(id)saleOfDayModel{
    NSLog(@"didReceiveSaleOfDay");
    SaleOfDayModel *saleOfDay = (SaleOfDayModel*)saleOfDayModel;
    NSLog(@"saleOfDay %@",saleOfDay);
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
    //set text in textView
    [self.textView setText:[self attributedStringFromDescriptions:saleOfDay.descriptions].string];
    [HUD hideUIBlockingIndicator];
    
}
#pragma mark - Helpers
-(NSAttributedString*)attributedStringFromDescriptions:(NSArray*)descriptions{
   // NSMutableAttributedString *fullAttrString = [[NSMutableAttributedString alloc] init];
    NSString *Fullstring = @"";
    for (SaleOfDayDescriptionModel *description in descriptions) {
        if (description.text.length>0) {
            Fullstring = [Fullstring stringByAppendingString:description.text];
        }
    }
    NSLog(@"fullString =%@",Fullstring);
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:Fullstring];
#warning TODO add links to item card view controller
    return attrString;
}
@end
