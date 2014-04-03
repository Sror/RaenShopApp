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
#import "MBProgressHUD.h"

typedef enum SocialButtonTags {
    SocialButtonTwitter,
    SocialButtonFacebook,
    SocialButtonVkontakte,
    SocialButtonGoogle
} SocialButtonTags;

@interface LoginViewController ()<RaenAPICommunicatorDelegate,SocializerDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    RaenAPICommunicator *_communicator;
    Socializer *_socializer;
    UIAlertView *_emailAlert;
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
    //get dict from user defaults
    [_socializer logOutFromSocial];
    [_communicator removeAuthDataFromDefaults];
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
    NSLog(@"didFailuerAPIAuthorizationWithResponse %@",response);
    [_communicator removeAuthDataFromDefaults];
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText= @"Error";
    HUD.detailsLabelText = response[@"error"];
    [HUD show:YES];
    [HUD hide:YES afterDelay:1.3];
    
}
-(void)didEmailRequest{
    NSLog(@"HAVE TO ADD EMAIL ADDRESS FOR LOGIN RAEN SHOP!");
    
    if (_socializer.socialUserEmail) {
       [_communicator registrationNewUserWithEmail:_socializer.socialUserEmail
                                         firstName:_socializer.socialUsername
                                          lastName:nil
                                             phone:nil
                                            avatar:nil
                                        socialLink:nil
                                  socialIdentifier:_socializer.socialIdentificator
                                       accessToken:_socializer.socialAccessToken
                                            userId:_socializer.socialUserId];
    }else{
        //show alert view with textfield for email
        [self showEmailAlertWithMessage:@"Пожалуйста введите Ваш email для завершения регистрации."];
    }
}
-(void)didExistEmail{
    NSLog(@"current email already exist");
    [self showEmailAlertWithMessage:[NSString stringWithFormat:@"%@ уже занят, пожалуйста введите другой email",_socializer.socialUserEmail]];
}

-(void)didSuccessAPIAuthorizedWithResponse:(NSDictionary *)response{
    MBProgressHUD *HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.labelText= @"Success";
    HUD.detailsLabelText = response[@"success"];
    [HUD show:YES];
    [HUD hide:YES afterDelay:2];
}

#pragma mark -
-(void)authorizedViaVK{
    NSLog(@"authorizedViaVK");
    [self updateUI];
    
    [_communicator authAPIVia:kVkontakteIdentifier
           withuserIdentifier:_socializer.socialUserId
                  accessToken:_socializer.socialAccessToken optionalParameters:nil];
    
}
-(void)authorizedViaFaceBook{
    NSLog(@"authorizedViaFaceBook");
    [self updateUI];
    [_communicator authAPIVia:kFacebookIdentifier
           withuserIdentifier:_socializer.socialUserId
                  accessToken:_socializer.socialAccessToken
           optionalParameters:nil];
    
}
-(void)authorizedViaGoogle{
    NSLog(@"authorizedViaGoogle");
    [self updateUI];
    [_communicator authAPIVia:kGoogleIdentifier
           withuserIdentifier:_socializer.socialUserId
                  accessToken:_socializer.socialAccessToken
           optionalParameters:nil];
}

-(void)showEmailAlertWithMessage:(NSString*)message {
    _emailAlert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Отмена", nil];
    _emailAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[_emailAlert textFieldAtIndex:0] setDelegate:self];
    [_emailAlert show];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"_emailAlertView button clicked %d",buttonIndex);
    if (buttonIndex == 0) {
        if (![self validateEmail:_socializer.socialUserEmail]) {
            [self showEmailAlertWithMessage:@"Вы ввели неверный email! Попробуйте еще раз"];
        }else{
            NSLog(@"finish registration with email %@",_socializer.socialUserEmail);
            if (_socializer.socialUserEmail) {
                
                [_communicator registrationNewUserWithEmail:_socializer.socialUserEmail firstName:_socializer.socialUsername lastName:nil phone:nil avatar:nil socialLink:nil socialIdentifier:_socializer.socialIdentificator accessToken:_socializer.socialAccessToken userId:_socializer.socialUserId];
            }
        }
    }
    if (buttonIndex == 1) {
        [_socializer logOutFromSocial];
        [_communicator removeAuthDataFromDefaults];
        [self updateUI];
    }
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField{
    _socializer.socialUserEmail = textField.text;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([self validateEmail:textField.text]) {
        return YES;
    }
    return NO;
}
- (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}
@end
