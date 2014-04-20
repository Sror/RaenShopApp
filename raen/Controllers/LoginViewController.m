//
//  LoginViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 18.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "LoginViewController.h"
#import "RaenAPICommunicator.h"
#import "Socializer.h"
#import "ProfileCell.h"
#import "MBProgressHUD.h"
#import "UserInfoModel.h"
#import "UIImageView+WebCache.h"
#import "OrderCell.h"

typedef enum SocialButtonTags {
    SocialButtonTwitter,
    SocialButtonFacebook,
    SocialButtonVkontakte,
    SocialButtonGoogle
} SocialButtonTags;

@interface LoginViewController ()<RaenAPICommunicatorDelegate,SocializerDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
{
    UIAlertView *_emailAlert;
    NSString * _tmpUserEmail;
    NSString* _userPassword;
    UserInfoModel* _userInfo;
}

@property (weak, nonatomic) IBOutlet UIView *signInSubview;

@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *FacebookButton;
@property (weak, nonatomic) IBOutlet UIButton *vkontakteButton;
@property (weak, nonatomic) IBOutlet UIButton *googleButton;
@property (weak, nonatomic) IBOutlet UILabel *loginViaLabel;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

- (IBAction)socialButtonTapped:(id)sender;




@end

@implementation LoginViewController

-(void)viewDidAppear:(BOOL)animated{
    [RaenAPICommunicator sharedManager].delegate = self;
    [Socializer sharedManager].delegate = self;
    //add observer for twitter accounts store
    if ([[Socializer sharedManager].socialIdFromDefaults isEqualToString:@"Twitter"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.signInSubview.layer setCornerRadius:5.0];
    [self.signInButton.layer setCornerRadius:5.0];
    
    self.tableView.hidden = YES;
    [self updateUI];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    

   // [self updateUI];

}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - setupUI
-(void)updateUI
{
    if ([Socializer sharedManager].isAuthorizedAnySocial)
    {
        [[RaenAPICommunicator sharedManager]  userInfo];
        [[RaenAPICommunicator sharedManager] userOrders];
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Выход"
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(logoutButtonPressed)];
        
        [self.navigationItem setRightBarButtonItem:logoutButton animated:YES];
        [self.signInSubview setHidden:YES];
       // [self.tableView reloadData];
        [self.tableView setHidden:NO];
    }else
    {
        [self.navigationItem setRightBarButtonItem:nil];
        [self.tableView setHidden:YES];
        [self.signInSubview setHidden:NO];
    }
}

#pragma mark - RaenAPICommunocatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

-(void)didReceiveUserInfo:(id)userInfo{
    NSLog(@"didReceiveUserInfo %@",(UserInfoModel*)userInfo);
    _userInfo = (UserInfoModel*)userInfo;
    [self.tableView reloadData];
    
}
-(void)didReceiveUserOrders:(NSDictionary *)userOrders{
    NSLog(@"didReceiveUserOrders %@",userOrders);
}

#pragma mark - socialButtonTapped

- (IBAction)socialButtonTapped:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    switch (((UIButton*)sender).tag) {
        case SocialButtonTwitter:
            [self _refreshTwitterAccounts];
            //[[Socializer sharedManager] loginTwitter];
            break;
            case SocialButtonFacebook:
            [[Socializer sharedManager] loginFacebook];
            break;
            case SocialButtonVkontakte:
            [[Socializer sharedManager] loginVK];
            break;
            case SocialButtonGoogle:
            [[Socializer sharedManager] loginGoogle];
        default:
            break;
    }
    
}

-(void)logoutButtonPressed{
    [[Socializer sharedManager] logOutFromCurrentSocial];
    [[RaenAPICommunicator sharedManager]deleteCookies];
    [[RaenAPICommunicator sharedManager]deleteCookieFromLocalStorage];
}


#pragma mark - STEP 1 RESPONSES
#pragma mark - SocializerDelegate methods
-(void)shouldShowVCCaptchaVC:(VKCaptchaViewController *)viewController{
    [viewController presentIn:self];
}
-(void)successfullyAuthorizedToSocialNetwork{
    //[self updateUI];
    //Step 2 - send request to RAEN API
    [[RaenAPICommunicator sharedManager] authAPIVia:[Socializer sharedManager].socialIdentificator
                                 withuserIdentifier:[Socializer sharedManager].socialUserId
                                        accessToken:[Socializer sharedManager].socialAccessToken
                                 optionalParameters:nil];
}
-(void)failureAuthorization{
    [self updateUI];
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)successLogout{
    NSLog(@"got successLogout");
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self updateUI];
    
}

#pragma mark - STEP2 RESPONSES
#pragma mark - RaenAPICommunicator delegation methods
-(void)didSuccessAPIAuthorizedWithResponse:(NSDictionary *)response{
    NSLog(@"didSuccessAPIAuthorizedWithResponse %@",response);
    [self updateUI];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}
-(void)didFailuerAPIAuthorizationWithResponse:(NSDictionary *)response{
    NSLog(@"didFailuerAPIAuthorizationWithResponse %@",response);
    [[Socializer sharedManager] logOutFromCurrentSocial];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:response[@"login_error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
}

-(void)didEmailRequest{
    
    if ([Socializer sharedManager].socialUserEmail.length>0) {
        [[RaenAPICommunicator sharedManager] registrationNewUserWithEmail:[Socializer sharedManager].socialUserEmail
                                                                firstName:[Socializer sharedManager].socialUsername
                                                                 lastName:nil
                                                                    phone:nil
                                                                   avatar:nil
                                                               socialLink:nil
                                                         socialIdentifier:[Socializer sharedManager].socialIdentificator
                                                              accessToken:[Socializer sharedManager].socialAccessToken
                                                                   userId:[Socializer sharedManager].socialUserId];
    }else{
        //show alert view with textfield for email
        [self showEmailAlertWithMessage:@"Пожалуйста введите Ваш email для завершения регистрации."];
    }
}

-(void)didExistEmail{
    NSLog(@"current email already exist");
    [self showEmailAlertWithMessage:[NSString stringWithFormat:@"%@ уже занят, пожалуйста введите другой email",[Socializer sharedManager].socialUserEmail]];
}



#pragma mark - Email Alert view initialization
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
        if (![self validateEmail:_tmpUserEmail]) {
            [self showEmailAlertWithMessage:@"Вы ввели неверный email! Попробуйте еще раз"];
        }else{
            NSLog(@"finish registration with email %@",[Socializer sharedManager].socialUserEmail);
            if (_tmpUserEmail) {
                [[RaenAPICommunicator sharedManager] registrationNewUserWithEmail:_tmpUserEmail
                                                                        firstName:[Socializer sharedManager].socialUsername
                                                                         lastName:nil
                                                                            phone:nil
                                                                           avatar:nil
                                                                       socialLink:nil
                                                                 socialIdentifier:[Socializer sharedManager].socialIdentificator
                                                                      accessToken:[Socializer sharedManager].socialAccessToken
                                                                           userId:[Socializer sharedManager].socialUserId];
            }
        }
    }
    if (buttonIndex == 1)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [[Socializer sharedManager] logOutFromCurrentSocial];
    }
}

#pragma mark - UITableView DataSource
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 90;
    }

    return 44;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section ==0) {
        return 1;
    }
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    //USER PROFILE
    if (indexPath.section == 0)
    {
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
        cell.usernameLabel.text = _userInfo.username;
        cell.userEmailLabel.text = _userInfo.email;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:_userInfo.avatar]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            if (!image) {
                [cell.avatarImageView setImage:[UIImage imageNamed:@"no_avatar.png"]];
            }
            
        }];
       return  cell;
    }
    //ORDER CELL
    if (indexPath.section == 1) {
        OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell"];
        cell.numberAndDateLabel.text = @"order #1234 22.12.12";
        cell.statusLabel.text = @"orderStatus";
        return  cell;
    }
    
    return nil;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return @"Заказы";
    }
    return nil;
}
#pragma mark - UITextField delegation methods
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"textFieldDidBeginEditing");
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag!=1) {
        NSLog(@"_tmpUserEmail = %@",textField.text);
        _tmpUserEmail = textField.text;
    }
    if (textField.tag ==1) {
        _userPassword = textField.text;
        NSLog(@"user password %@",_userPassword);
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)validateEmail:(NSString *)emailStr
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailStr];
}

#pragma mark - Twitter
- (void)_refreshTwitterAccounts
{
    if (![TWAPIManager isLocalTwitterAccountAvailable]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Вы должны добавить twitter аккаунт в настройках телефона"  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    else {
        [[Socializer sharedManager] obtainAccessToAccountsWithBlock:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (granted) {
                    NSLog(@"GRANTED!");
                    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Выберите Twitter аккаунт"
                                                                       delegate:self
                                                              cancelButtonTitle:nil
                                                         destructiveButtonTitle:nil
                                                              otherButtonTitles:nil];
                    for (ACAccount *account in [Socializer sharedManager].twitterAccounts) {
                        [sheet addButtonWithTitle:account.username];
                    }
                    sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Отмена"];
                    [sheet showInView:self.tableView];
                }
                else {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Twitter" message:@"Не получен доступ к Twitter аккаунтам" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                    [[Socializer sharedManager] logOutFromCurrentSocial];
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    NSLog(@"You were not granted access to the Twitter accounts.");
                }
            });
        }];
    }
}


#pragma mark - UIActionSheet Delegation methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [[Socializer sharedManager] loginTwitterAccountAtIndex:buttonIndex];
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }
    
}
#pragma mark - Keyboard helpers
/*
-(UIToolbar*)keyboardToolBar{
    //portrait toolbar only
    UIToolbar* keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 40.0)];
    [keyboardToolBar setBarStyle:UIBarStyleBlack];
    [keyboardToolBar setTranslucent:YES];
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(keyboardDonePressed)];
    keyboardToolBar.items = @[flexSpace,doneButton];
    [keyboardToolBar.layer setCornerRadius:3.0];
    return keyboardToolBar;
    
}
- (void)keyboardDonePressed{
    [self.view resignFirstResponder];
    [self signInButtonPressed:nil];
    //[self.view endEditing:YES];
}
 */
#pragma mark - Sign in view email/pass button pressed
- (IBAction)signInButtonPressed:(id)sender {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    if (self.emailTextField.text.length>0 && self.passwordTextField.text.length>0) {
        self.emailTextField.text = _tmpUserEmail;
        self.passwordTextField.text = _userPassword;
        if (![self validateEmail:_tmpUserEmail]) {
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Вы ввели неверный email! Попробуйте еще раз" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
        }else{
            [[RaenAPICommunicator sharedManager] authViaEmail:_tmpUserEmail andPassword:_userPassword];
        }
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGPoint newPoint = self.view.center;
    if (screenHeight<=480) {
        newPoint.y  = self.view.center.y - 130;
    }else if (screenHeight>480 && screenHeight<=568){
         newPoint.y  = self.view.center.y - 100;
    }
    NSLog(@"newPoin x=%f y=%f",newPoint.x,newPoint.y);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.signInSubview.center = newPoint;
    }];
    
}
- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.5  animations:^{
        self.signInSubview.center = self.view.center;
    }];
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
