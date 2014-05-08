//
//  LoginViewController.m
//  raenapp
//
//  Created by Alexey Ivanov on 18.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "ProfileViewController.h"
#import "RaenAPICommunicator.h"
#import "Socializer.h"
#import "ProfileCell.h"
#import "MBProgressHUD.h"
#import "UserInfoModel.h"
#import "UIImageView+WebCache.h"
#import "OrderCell.h"
#import "OrderModel.h"
#import "OrderViewController.h"

#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"


typedef enum SocialButtonTags {
    SocialButtonTwitter,
    SocialButtonFacebook,
    SocialButtonVkontakte,
    SocialButtonGoogle
} SocialButtonTags;

@interface ProfileViewController ()<RaenAPICommunicatorDelegate,SocializerDelegate,UIAlertViewDelegate,UITextFieldDelegate,UIActionSheetDelegate>
{
    RaenAPICommunicator * _communicator;
    UIAlertView *_emailAlert;
    NSString * _tmpUserEmail;
    NSString* _userPassword;
    UserInfoModel* _userInfo;
    UIRefreshControl* _refreshControl;
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

@implementation ProfileViewController

-(void)viewDidAppear:(BOOL)animated{
    //add observer for twitter accounts store
    if ([[Socializer sharedManager].socialIdFromDefaults isEqualToString:@"Twitter"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshTwitterAccounts) name:ACAccountStoreDidChangeNotification object:nil];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName
           value:@"Profile Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [Socializer sharedManager].delegate = self;
    _communicator = [[RaenAPICommunicator alloc] init];
    _communicator.delegate = self;
    
    [self.signInSubview.layer setCornerRadius:5.0];
    [self.signInButton.layer setCornerRadius:5.0];
    [self setupRefreshControl];
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
}

#pragma mark - UIRefreshControl
-(void)setupRefreshControl{
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(updateUI) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:_refreshControl];
}


#pragma mark - setupUI
-(void)updateUI
{
    if ([Socializer sharedManager].isAuthorizedAnySocial)
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [_communicator  userInfo];
        [_communicator userOrders];
        
        UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                         initWithTitle:@"Выход"
                                         style:UIBarButtonItemStylePlain
                                         target:self
                                         action:@selector(logoutButtonPressed)];
        
        [self.navigationItem setRightBarButtonItem:logoutButton animated:YES];
        [self.signInSubview setHidden:YES];
        [self.tableView setHidden:NO];
        [self.tableView reloadData];
    }else
    {
        [self.navigationItem setRightBarButtonItem:nil];
        [self.tableView setHidden:YES];
        [self.signInSubview setHidden:NO];
        self.emailTextField.text = nil;
        self.passwordTextField.text = nil;
        [_refreshControl endRefreshing];
    }
}

#pragma mark - RaenAPICommunocatorDelegate
-(void)fetchingFailedWithError:(JSONModelError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_refreshControl endRefreshing];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Проверьте подключение к интернету"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles: nil];
    [alert show];
}

-(void)didReceiveUserInfo:(UserInfoModel*)userInfo
{
   [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_refreshControl endRefreshing];
    _userInfo = userInfo;
    if (userInfo.phone.length>1)
    {
        [Socializer sharedManager].userPhone = userInfo.phone;
        [[Socializer sharedManager] saveAuthUserDataToDefaults];
    }
    [self.tableView reloadData];
    
}
-(void)didReceiveUserOrders:(NSArray*)userOrders{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_refreshControl endRefreshing];
    self.orders = userOrders;
    [self.tableView reloadData];
}

#pragma mark - socialButtonTapped

- (IBAction)socialButtonTapped:(id)sender {
    //hide keyboard
    [_emailTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  
    switch (((UIButton*)sender).tag) {
        case SocialButtonTwitter:
            [self _refreshTwitterAccounts];
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
    [_communicator deleteCookies];
    [_communicator deleteCookieFromLocalStorage];
    [_communicator getItemsFromCart];
}


#pragma mark - STEP 1 RESPONSES
#pragma mark - SocializerDelegate methods
-(void)shouldShowVCCaptchaVC:(VKCaptchaViewController *)viewController{
    [viewController presentIn:self];
}
-(void)successfullyAuthorizedToSocialNetwork{
    //Step 2 - send request to RAEN API
    [_communicator authAPIVia:[Socializer sharedManager].socialIdentificator
                                 withuserIdentifier:[Socializer sharedManager].socialUserId
                                        accessToken:[Socializer sharedManager].socialAccessToken
                                 optionalParameters:nil];
}
-(void)failureAuthorization{
    [self updateUI];
    [MBProgressHUD hideHUDForView:self.view animated:YES];

}

-(void)successLogout{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [self updateUI];
}

#pragma mark - STEP2 RESPONSES
#pragma mark - RaenAPICommunicator delegation methods
-(void)didSuccessAPIAuthorizedWithResponse:(NSDictionary *)response{
    //UPDATE CART BADGE
    [_communicator getItemsFromCart];
    //
    [self updateUI];
    [MBProgressHUD hideHUDForView:self.view
                         animated:YES];
    
   
}
-(void)didFailuerAPIAuthorizationWithResponse:(NSDictionary *)response{
    NSLog(@"didFailuerAPIAuthorizationWithResponse %@",response);
    [[Socializer sharedManager] logOutFromCurrentSocial];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:response[@"login_error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    
    
    
}

-(void)didReceiveCartItems:(NSArray *)items{
   [self.tabBarController.tabBar.items[3] setBadgeValue:[NSString stringWithFormat:@"%i",items.count]];
}

-(void)didEmailRequest{
    
    if ([Socializer sharedManager].socialUserEmail.length>0) {
        [_communicator       signInNewUserWithEmail:[Socializer sharedManager].socialUserEmail
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
        [self rotateSignInSubviewWithCompletion:^{
            [self showEmailAlertWithMessage:@"Пожалуйста введите Ваш email для завершения регистрации."];
        }];
    }
}

-(void)didExistEmail{
    [self rotateSignInSubviewWithCompletion:^{
        [self showEmailAlertWithMessage:[NSString stringWithFormat:@"%@ уже занят, пожалуйста введите другой email",
                                         [Socializer sharedManager].socialUserEmail]];

    }];
}


#pragma mark - Email Alert view initialization
-(void)showEmailAlertWithMessage:(NSString*)message {
    _emailAlert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Отмена", nil];
    _emailAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[_emailAlert textFieldAtIndex:0] setDelegate:self];
    [_emailAlert show];
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
    return _orders.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
   //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
    //USER PROFILE
    if (indexPath.section == 0)
    {
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
        cell.usernameLabel.text = _userInfo.username;
        cell.userEmailLabel.text = _userInfo.email;
        cell.userPhoneLabel.text = _userInfo.phone;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:_userInfo.avatar]
                             placeholderImage:[UIImage imageNamed:@"no_avatar.png"]
                                    completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType)
        {
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        }];
 
       return  cell;
    }
    //ORDER CELL
    if (indexPath.section == 1) {
        OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell"];
        OrderModel *order = self.orders[indexPath.row];
        cell.numberAndDateLabel.text = [NSString stringWithFormat:@"№%@",order.id];
        cell.statusLabel.text = [order.status isEqualToString:@"0"] ? nil:order.status;
        
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

#pragma mark - UITableView delegation methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section !=0) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        OrderModel *order = self.orders[indexPath.row];
        NSArray *goodsInOrder = order.goodsInOrder;
        [self performSegueWithIdentifier:@"toOrderVC" sender:goodsInOrder];
    }
}


#pragma mark - UITextField delegation methods
-(void)textFieldDidBeginEditing:(UITextField *)textField{

}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField.tag!=1) {
        _tmpUserEmail = textField.text;
    }
    if (textField.tag ==1) {
        _userPassword = textField.text;
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{

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
#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        if (![self validateEmail:_tmpUserEmail]) {
           [self rotateSignInSubviewWithCompletion:^{
               [self showEmailAlertWithMessage:@"Вы ввели неверный email! Попробуйте еще раз"];
           }];
            
        }else{
            if (_tmpUserEmail) {
                [_communicator       signInNewUserWithEmail:_tmpUserEmail
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

#pragma mark - Navigation methods
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toOrderVC"]) {
        OrderViewController *orderVC = segue.destinationViewController;
        orderVC.goodies = sender;
    }
}

#pragma mark - Sign in view email/pass button pressed
- (IBAction)signInButtonPressed:(id)sender {
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    if (self.emailTextField.text.length>0 && self.passwordTextField.text.length>0) {
        self.emailTextField.text = _tmpUserEmail;
        self.passwordTextField.text = _userPassword;
        if (![self validateEmail:_tmpUserEmail]) {
            
            [self rotateSignInSubviewWithCompletion:^{
                UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Ошибка" message:@"Вы ввели неверный email! Попробуйте еще раз" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }];
            
        }else{
            [_communicator authViaEmail:_tmpUserEmail andPassword:_userPassword];
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
    [UIView animateWithDuration:0.5 animations:^{
        self.signInSubview.center = newPoint;
    }];
    
}
- (void)keyboardWillHide:(NSNotification *)notification{
    [UIView animateWithDuration:0.5  animations:^{
        self.signInSubview.center = self.view.center;
    }];
}

#pragma mark - SignInSubView animation
-(void)rotateSignInSubviewWithCompletion:(void(^)(void))completionBlock{
  
    [UIView animateWithDuration:0.2 animations:^{
        CGFloat rotationAngleDegreesLeft = -10;
        CGFloat rotationAngleRadiansLeft = rotationAngleDegreesLeft * (M_PI/180);
        CATransform3D transform = CATransform3DIdentity;
        transform = CATransform3DRotate(transform, rotationAngleRadiansLeft, 0.0, 0.0, 1.0);
        self.signInSubview.layer.transform =transform;
       
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.1 animations:^{
            CGFloat rotationAngleDegreesRight = +20;
            CGFloat rotationAngleRadiansRight = rotationAngleDegreesRight * (M_PI/180);
            CATransform3D transform = CATransform3DIdentity;
            transform = CATransform3DRotate(transform, rotationAngleRadiansRight, 0.0, 0.0, 1.0);
            self.signInSubview.layer.transform =transform;
            
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                CATransform3D transform = CATransform3DIdentity;
                transform = CATransform3DRotate(transform, 0, 0.0, 0.0, 1.0);
                self.signInSubview.layer.transform =transform;
            } completion:^(BOOL finished) {
                completionBlock();
            }];
            
        }];
    }];
}

#pragma mark - didReceiveMemoryWarning

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
