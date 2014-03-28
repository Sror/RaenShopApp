//
//  LoginViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 18.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "RaenAPICommunicator.h"
#import "Socializer.h"
#import <FacebookSDK/FacebookSDK.h>
#import "HUD.h"

typedef enum SocialButtonTags {
    SocialButtonTwitter,
    SocialButtonFacebook,
    SocialButtonVkontakte,
    SocialButtonGoogle
} SocialButtonTags;

@interface LoginViewController ()<RaenAPICommunicatorDelegate,SocializerDelegate>{
    RaenAPICommunicator *_communicator;
    Socializer *_socializer;
}
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *FacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *vkontakteButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UIButton *socialLogoutButton;

- (IBAction)socialButtonTapped:(id)sender;
- (IBAction)socialLogoutButtonPressed;


@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	_communicator = [[AppDelegate instance] communicator];
    _socializer =[[AppDelegate instance] socializer];
    _socializer.delegate = self;
    _communicator.delegate = self;
    [self updateUI];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - setupUI
-(void)updateUI{
    NSLog(@"updating UI");
    NSLog(@"\n_socialAccessToken=%@\n_socialUserId=%@\n_socialUsername %@\n_socialUserEmail %@",_socializer.socialAccessToken,_socializer.socialUserId,_socializer.socialUsername,_socializer.socialUserEmail);
    
    NSLog(@"is auth in loginVC ? %@",_socializer.isAuthorizedViaSocial ? @"YES":@"NO");
//    NSString *title =[_socializer whichSocialAuthorized] ;
//    if (!title) {
//        title = @"Not Authorized";
//    }
//    self.navigationItem.title = title;
    self.usernameLabel.text = _socializer.socialUsername;;
    if (_socializer.isAuthorizedViaSocial) {
        [self.usernameLabel setHidden:NO];
        [self.avatar setHidden:NO];
        [self.twitterButton setHidden:YES];
        [self.FacebookButton setHidden:YES];
        [self.vkontakteButton setHidden:YES];
        [self.googleButton setHidden:YES];
        [self.socialLogoutButton setHidden:NO];
    }else{
        [self.usernameLabel setHidden:YES];
        [self.avatar setHidden:YES];
        [self.twitterButton setHidden:NO];
        [self.FacebookButton setHidden:NO];
        [self.vkontakteButton setHidden:NO];
        [self.googleButton setHidden:NO];
        [self.socialLogoutButton setHidden:YES];
    }
}

#pragma mark - RaenAPICommunocatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error{
    NSLog(@"fetchingFailedWithError");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}
#pragma mark - socialButtonTapped
- (IBAction)socialButtonTapped:(id)sender {
    switch (((UIButton*)sender).tag) {
        case SocialButtonTwitter:
            [self loginTwitter];
            break;
            case SocialButtonFacebook:
            [self loginFacebook];
            break;
            case SocialButtonVkontakte:
            [self loginVkontakte];
            break;
            case SocialButtonGoogle:
            [self loginGoogle];
        default:
            break;
    }
}

- (IBAction)socialLogoutButtonPressed {
#warning TODO logout current social
    NSString *socialIdentifier = [_socializer whichSocialAuthorized];
    if ([socialIdentifier isEqualToString:kVkontakteIdentifier]) {
        [_socializer logOutVK];
    }
    if ([socialIdentifier isEqualToString:kFacebookIdentifier]) {
        [_socializer logOutFacebook];
    }
    if ([socialIdentifier isEqualToString:kGoogleIdentifier]) {
        [_socializer logOutGoogle];
    }
    [self updateUI];
}
- (IBAction)cancelButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 
-(void)loginTwitter{
    NSLog(@"loginTwitter");
    
}
-(void)loginFacebook{
    NSLog(@"loginFacebook");
    [_socializer loginFacebook];
    
}
-(void)loginVkontakte{
    NSLog(@"loginVkontakte");
    [_socializer loginVK];
    
}
-(void)loginGoogle{
    NSLog(@"loginGoogle");
    [_socializer loginGoogle];
    
}

#pragma mark - SocializerDelegate methods
-(void)didFailuerAPIAuthorizationWithResponse:(NSDictionary *)response{
    [HUD showTimedAlertWithTitle:@"Error" text:response[@"error"] withTimeout:1.2];
}
-(void)didEmailRequest{
    NSLog(@"HAVE TO ADD EMAIL ADDRESS FOR LOGIN RAEN SHOP!");
}
-(void)didSuccessAPIAuthorizedWithResponse:(NSDictionary *)response{
    [HUD showTimedAlertWithTitle:@"Success" text:response[@"success"] withTimeout:1.2];
}

#pragma mark -

-(void)authorizedViaVK{
    NSLog(@"authorizedViaVK");
    [self updateUI];
    [_communicator authAPIVia:kVkontakteIdentifier withuserIdentifier:_socializer.socialUserId accessToken:_socializer.socialAccessToken];
    
}
-(void)authorizedViaFaceBook{
    NSLog(@"authorizedViaFaceBook");
    [self updateUI];
    [_communicator authAPIVia:kFacebookIdentifier withuserIdentifier:_socializer.socialUserId accessToken:_socializer.socialAccessToken];
    
}
-(void)authorizedViaGoogle{
    NSLog(@"authorizedViaGoogle");
    [self updateUI];
    [_communicator authAPIVia:kGoogleIdentifier withuserIdentifier:_socializer.socialUserId accessToken:_socializer.socialAccessToken];
}
@end
