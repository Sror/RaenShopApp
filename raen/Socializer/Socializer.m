//
//  Socializer.m
//  raenapp
//
//  Created by Alexey Ivanov on 18.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "Socializer.h"
#import <Social/Social.h>
#import "NSString+Additions.h"


NSString *kVkontakteIdentifier = @"Vkontakte";
NSString *kGoogleIdentifier = @"Google";
NSString *kTwitterIdentifier = @"Twitter";
NSString *kFacebookIdentifier = @"Facebook";

#define kGoogleClientID @"231217279677-ebftkbl3ad5jbhdr1ha7dilcm2otvpil.apps.googleusercontent.com"
#define kGoogleClientSecret @"vGLokxZqDzF5HgIpllGl0Hao"
#define kShouldSaveInKeychainKey  @"shouldSaveInKeychain"
#define kKeychainItemName  @"OAuth РАЁН: Google+"

NSString* kVKAppId = @"4237186";
NSString* kFacebookAppID = @"220082361532667";

NSString* kSocializerAuthDict = @"SOCIALIZER_SOCIAL_AUTH_DICT";
NSString* kSocializerRaenAPIToken = @"SOCIALIZER_RAEN_API_TOKEN";
NSString* kSocializerSocialIdentifier = @"SOCIALIZER_SOCIAL_IDENTIFIER";
NSString* kSocializerSocialAccessToken =@"SOCIALIZER_SOCIAL_ACCESS_TOKEN";
NSString* kSocializerSocialUserID = @"SOCIALIZER_SOCIAL_USER_ID";
NSString* kSocializerSocialUserFullName = @"SOCIALIZER_SOCIAL_USER_FULL_NAME";
NSString* kSocializerSocialUserEmail = @"SOCIALIZER_SOCIAL_USER_EMAIL";
NSString* kUserPhone = @"RAEN_USER_PHONE";

@interface Socializer ()<VKSdkDelegate>{
    int mNetworkActivityCounter;
}
@end

@implementation Socializer

+ (Socializer*)sharedManager {
    static Socializer * __sharedManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedManager = [[Socializer alloc] init];
    });
    return __sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.twitterAPIManager = [[TWAPIManager alloc] init];
        [self setPropertiesFromUserDefaults];
    }
    return self;
}

-(void)setPropertiesFromUserDefaults{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kSocializerAuthDict]) {
        self.socialIdentificator = [self socialIdFromDefaults];
        self.raenAPIToken = [self raenAPITokenFromDefaults];
        self.socialUsername = [self socialUserNameFromDefaults];
        self.socialAccessToken = [self socialTokenFromDefaults];
        self.socialUserEmail = [self socialUserEmailFromDefaults];
        self.userPhone = [self userPhoneFromDefaults];
        _authorizedAnySocial = self.socialIdentificator ? YES:NO;
    }
}

#pragma mark - Google session initializer
/*
-(GPPSignIn *)googleSignIn{
    if (_googleSignIn ==nil) {
        _googleSignIn = [GPPSignIn sharedInstance];
        _googleSignIn.attemptSSO = YES;
        _googleSignIn.shouldFetchGooglePlusUser = YES;
        _googleSignIn.shouldFetchGoogleUserEmail = YES;
        _googleSignIn.shouldFetchGoogleUserID = YES;
        _googleSignIn.clientID = kGoogleClientID;
        _googleSignIn.scopes = @[kGTLAuthScopePlusLogin];
        _googleSignIn.delegate = self;
    }
    return _googleSignIn;
}
*/

#pragma mark - Login methods
-(void)loginVK{
    [VKSdk initializeWithDelegate:self andAppId:kVKAppId];
    if ([VKSdk wakeUpSession])
    {
        _socialAccessToken = [VKSdk getAccessToken].accessToken;
        _socialUserId = [VKSdk getAccessToken].userId;
        _socialIdentificator = kVkontakteIdentifier;
        [self saveAuthUserDataToDefaults];
        _authorizedAnySocial = [self socialIdFromDefaults] ? YES : NO;
        [self vkUserinfo];
    }else{
        NSArray *scope = @[VK_PER_FRIENDS,VK_PER_WALL,VK_PER_PHOTOS,VK_PER_NOHTTPS];
        //was[VKSdk authorize:scope revokeAccess:YES];
        //have to use internal web view for authorization
        
        [VKSdk authorize:scope revokeAccess:YES forceOAuth:YES inApp:YES];
    }
}

-(void)loginFacebook{
    NSArray *fbPermissions = @[@"basic_info",
                               @"email",
                               @"user_likes"
                               ];
    BOOL isFBSessionActive =  [FBSession openActiveSessionWithReadPermissions:fbPermissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState status, NSError *error)
    {
        if (!error)
        {
            _fbSession = session;
                    if ([_fbSession isOpen]) {
                        _socialIdentificator = kFacebookIdentifier;
                       _socialAccessToken = _fbSession.accessTokenData.accessToken;
                        [self fbUserInfo];
                           
                   }else{
                       NSLog(@"---error to open facebook session--- %@",error);
                       [self handleFacebookSessionError];
                   }
        }
                                                      }];
    if (!isFBSessionActive) {
//open new facebook sessio
        _fbSession = [[FBSession alloc] initWithPermissions:fbPermissions];
        [_fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (!error) {
                if ([_fbSession isOpen]) {
                    _socialIdentificator = kFacebookIdentifier;
                    _socialAccessToken = _fbSession.accessTokenData.accessToken;
                    [self fbUserInfo];
                }else{
                    NSLog(@"---error to open facebook session--- %@",error);
                }
            }
        }];
    }
}

-(void)loginGoogle{
//    [self.googleSignIn authenticate];
    
GTMOAuth2ViewControllerTouch *controller = [[GTMOAuth2ViewControllerTouch alloc]
                                            initWithScope:kGTLAuthScopePlusLogin
                                            clientID:kGoogleClientID
                                            clientSecret:kGoogleClientSecret
                                            keychainItemName:kKeychainItemName
                                                                             completionHandler:^(GTMOAuth2ViewControllerTouch *viewController, GTMOAuth2Authentication *auth, NSError *error) {
                                                                                 if (!error) {
                                                                                     _socialIdentificator = kGoogleIdentifier;
                                                                                     _socialAccessToken = auth.accessToken;
                                                                                     _socialUserEmail = viewController.signIn.userProfile[@"email"];
                                                                                     _socialUserId = viewController.signIn.userProfile[@"sub"];
                                                                                     _socialUsername = viewController.signIn.userProfile[@"name"];
                                                                                     //user avatar link userProfile[@"picture"]

                                                                                     _authorizedAnySocial = [auth canAuthorize];
                                                                                     if (_authorizedAnySocial) {
                                                                                         [self saveAuthUserDataToDefaults];
                                                                                         [self.delegate successfullyAuthorizedToSocialNetwork];
                                                                                     }
                                                                                 }else{
                                                                                     NSLog(@"--Google Authorization error %@--",error);
                                                                                    // [self.googleSignIn disconnect];
                                                                                     [self.delegate failureAuthorization];
                                                                                 }
                                                                             }];


    controller.signIn.shouldFetchGoogleUserEmail = YES;
    controller.signIn.shouldFetchGoogleUserProfile = YES;
    [self.delegate shouldPresentGoogleAuthViewController:controller];
    
}

-(void)loginTwitterAccountAtIndex:(NSInteger)index{
    _twitterAccount = _twitterAccounts[index];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_twitterAPIManager performReverseAuthForAccount:_twitterAccount
                                                                   withHandler:^(NSData *responseData, NSError *error) {
                                                                       [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                                                                       if (responseData) {
                                                                           NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                                                           NSLog(@"Reverse Auth process returned: %@", responseStr);
                                                                           
                                                                           NSString *token = [responseStr stringBetweenString:@"oauth_token=" andString:@"&"];
                                                                           [Socializer sharedManager].socialAccessToken = token;
                                                                           [self twitterUserInfo];
                                                                          
                                                                       }
                                                                       else {
                                                                           NSLog(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
                                                                       }
                                                                   }];
    
}
#pragma mark - Logout methods
-(void)logOutFromCurrentSocial
{
    NSLog(@"logOutFromSocial %@",[self socialIdFromDefaults]);
    if ([_socialIdentificator isEqualToString:kFacebookIdentifier]) {
        [self logOutFacebook];
    }
    if ([_socialIdentificator isEqualToString:kVkontakteIdentifier]) {
        [self logOutVK];
    }
    if ([_socialIdentificator isEqualToString:kGoogleIdentifier]) {
        [self logOutGoogle];
    }
    if ([_socialIdentificator isEqualToString:kTwitterIdentifier]) {
        [self logoutTwitter];
    }
    [self removeSocialData];
    NSLog(@"send success logout");
    [self.delegate successLogout];
    
}
-(void)logOutVK{
  
    [VKSdk forceLogout];
}
-(void)logOutGoogle{
    [[GPPSignIn sharedInstance] disconnect];
}
-(void)logOutFacebook{
    [_fbSession closeAndClearTokenInformation];
    _fbSession = nil;
    
}
-(void)logoutTwitter{
    NSLog(@"logoutTwitter");
    
}
-(void)removeSocialData
{
    _socialIdentificator = nil;
    _socialUserId = nil;
    _socialAccessToken = nil;
    _socialUserEmail = nil;
    _socialUsername = nil;
    _raenAPIToken = nil;
    _userPhone = nil;
    [self removeAuthDataFromDefaults];
}
#pragma mark - Twitter

- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.twitterAccounts = [_accountStore accountsWithAccountType:twitterType];
        }
        
        block(granted);
    };
    [_accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}

#pragma mark - Social user info methods
-(void)vkUserinfo{
    NSLog(@"getting VK user info");
    if (_authorizedAnySocial == YES)
    {
        VKRequest *userInfoRequest = [VKApi users].get;
        [userInfoRequest executeWithResultBlock:^(VKResponse *response) {
            NSArray *json = response.json;
            if ([json.firstObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *jsonDict = json.firstObject;
                _socialUsername = [NSString stringWithFormat:@"%@ %@",jsonDict[@"first_name"],jsonDict[@"last_name"]];
                _socialUserId =jsonDict[@"id"];

                [self saveAuthUserDataToDefaults];
                [self.delegate successfullyAuthorizedToSocialNetwork];
            }
        } errorBlock:^(NSError *error) {
            NSLog(@"---error to get VK.com user info %@---",error.description);
            
            [self removeAuthDataFromDefaults];
            _authorizedAnySocial = [self socialIdFromDefaults] ? YES : NO;
            [VKSdk forceLogout];
            [self loginVK];
            
        }];
    }else{
        //NOT AUTH VIA SOCIAL
        NSLog(@"error: can't get vk user info , cause _AuthorizedViaSocial == NO");
        [self removeAuthDataFromDefaults];
        _authorizedAnySocial = [self socialIdFromDefaults] ? YES : NO;
        [self.delegate failureAuthorization];
    }
}

-(void)fbUserInfo{
    NSLog(@"getting facebook user info");
    if ([_fbSession isOpen]) {
        [FBSession setActiveSession:_fbSession];
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary<FBGraphUser> *my = (NSDictionary<FBGraphUser> *) result;
                _socialUsername = [NSString stringWithFormat:@"%@ %@",my.first_name, my.last_name];
                _socialUserId = my.id;
                _socialUserEmail = result[@"email"];
                
                [self saveAuthUserDataToDefaults];
                _authorizedAnySocial = [self socialIdFromDefaults] ? YES : NO;
                if (_authorizedAnySocial) {
                    [self.delegate successfullyAuthorizedToSocialNetwork];
                }
                
            }else{
                NSLog(@"error to get facebook user info %@",error.description);
                [self.delegate failureAuthorization];
            }
        }];
    }
}
-(void)twitterUserInfo{
    NSLog(@"getting twitter user info");
    SLRequest *request =[SLRequest requestForServiceType:SLServiceTypeTwitter
                                           requestMethod:SLRequestMethodGET
                                                     URL:[NSURL URLWithString:@"https://api.twitter.com/1.1/account/verify_credentials.json"]
                                              parameters:nil];
    request.account =_twitterAccount;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if (error) {
            NSLog(@"error to get user info %@",error);
        }else{
            NSError *jsonError;
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseData
                                                                 options:NSJSONReadingAllowFragments
                                                                   error:&jsonError];
            if (jsonError) {
                NSLog(@"error to json serialization! %@",jsonError);
            }else{
                _socialUserId = json[@"id"];
                _socialIdentificator = kTwitterIdentifier;
                _socialUsername = json[@"name"];
                //_socialUserAvatar = json[@"profile_image_url"];
                [self saveAuthUserDataToDefaults];
                _authorizedAnySocial = [self socialIdFromDefaults] ? YES:NO;
                if (_authorizedAnySocial) {
                    [self.delegate successfullyAuthorizedToSocialNetwork];
                }
            }
        }
    }];
}

/* i use completion handler
#pragma mark - Google sign In Delegate methods
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error{
    if (!error) {
        _socialIdentificator = kGoogleIdentifier;
        _socialAccessToken = auth.accessToken;
        _socialUserEmail = auth.userEmail;
        _socialUserId = _googleSignIn.userID;
        _socialUsername = _googleSignIn.googlePlusUser.displayName;
        
        _authorizedAnySocial = [auth canAuthorize];
        if (_authorizedAnySocial) {
            [self saveAuthUserDataToDefaults];
            [self.delegate successfullyAuthorizedToSocialNetwork];
        }
    }else{
        NSLog(@"--Google Authorization error %@--",error);
        [self.googleSignIn disconnect];
        [self.delegate failureAuthorization];
    }
}
*/

#pragma mark - VKDelegate methods
-(void)vkSdkAcceptedUserToken:(VKAccessToken *)token{
    NSLog(@"vkSdkAcceptedUserToken %@",token);
    _socialAccessToken = token.accessToken;
    _socialUserId = token.userId;
    _socialIdentificator = kVkontakteIdentifier;
    [self saveAuthUserDataToDefaults];
    _authorizedAnySocial = [self socialIdFromDefaults] ? YES : NO;
    [self vkUserinfo];
}
-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError{
  
    VKCaptchaViewController * vc = [VKCaptchaViewController captchaControllerWithError:captchaError];

    [self.delegate shouldShowVCCaptchaVC:vc];
   
}
-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken{
 NSLog(@"vkSdkReceivedNewToken %@",newToken);
    _socialAccessToken = newToken.accessToken;
    _socialUserId = newToken.userId;
    _socialIdentificator = kVkontakteIdentifier;
    [self saveAuthUserDataToDefaults];
    _authorizedAnySocial = [self socialIdFromDefaults] ? YES : NO;
    [self vkUserinfo];
    
}
-(void)vkSdkRenewedToken:(VKAccessToken *)newToken{
    NSLog(@"vkSdkRenewedToken %@",newToken);
    _socialAccessToken = newToken.accessToken;
    _socialUserId = newToken.userId;
    _socialIdentificator = kVkontakteIdentifier;
    [self saveAuthUserDataToDefaults];
    _authorizedAnySocial = [self socialIdFromDefaults] ? YES : NO;
    [self vkUserinfo];
}

-(void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken{
    NSLog(@"-------vkSdkTokenHasExpired! %@",expiredToken);
    NSArray *scope = @[VK_PER_FRIENDS,VK_PER_WALL,VK_PER_PHOTOS,VK_PER_NOHTTPS];
    [VKSdk authorize:scope revokeAccess:YES];
}
-(void)vkSdkUserDeniedAccess:(VKError *)authorizationError{
    [self.delegate failureAuthorization];
}

-(void)vkSdkShouldPresentViewController:(UIViewController *)controller{
    NSLog(@"vkSdkShouldPresentViewController");
    [self.delegate shouldPresentVKViewController:controller];
}
#pragma mark - FaceBook Delegation methods
-(void)handleFacebookSessionError{
    [self.delegate failureAuthorization];
}

#pragma mark - UserDefaults manager
- (NSString*)accessTokenFromDefaults{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *tmpDict = [defaults objectForKey:kSocializerAuthDict];
    if (tmpDict) {
        return  tmpDict[kSocializerSocialAccessToken];
    }
    return nil;
}
- (NSString*)socialIdFromDefaults{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSocializerAuthDict][kSocializerSocialIdentifier];
}

- (NSString*)raenAPITokenFromDefaults{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kSocializerAuthDict][kSocializerRaenAPIToken];
}
- (NSString*)socialUserEmailFromDefaults{
    return  [[NSUserDefaults standardUserDefaults]objectForKey:kSocializerAuthDict][kSocializerSocialUserEmail];
}
- (NSString*)socialUserNameFromDefaults{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSocializerAuthDict][kSocializerSocialUserFullName];
}
- (NSString*)socialUserIdFromDefaults{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSocializerAuthDict][kSocializerSocialUserID];
    
}
-(NSString *)socialTokenFromDefaults{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSocializerAuthDict][kSocializerSocialAccessToken];
}
-(NSString* )userPhoneFromDefaults{
    return [[NSUserDefaults standardUserDefaults]objectForKey:kSocializerAuthDict][kUserPhone];
}
- (void)saveAuthUserDataToDefaults{
    NSLog(@"saving auth User data to user defaults");
   
    NSDictionary *authDict = @{kSocializerSocialIdentifier :_socialIdentificator ? _socialIdentificator : @"",
                               kSocializerSocialAccessToken : _socialAccessToken ? _socialAccessToken :@"",
                               kSocializerRaenAPIToken :_raenAPIToken ? _raenAPIToken :@"",
                               kSocializerSocialUserEmail: _socialUserEmail ? _socialUserEmail: @"",
                               kSocializerSocialUserFullName:_socialUsername ? _socialUsername:@"",
                               kSocializerSocialUserID : _socialUserId ?_socialUserId :@"",
                               kUserPhone :_userPhone ?_userPhone:@""
                               };
    
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:authDict forKey:kSocializerAuthDict];
    [defaults synchronize];
    //
    [self setPropertiesFromUserDefaults];
}

-(void)removeAuthDataFromDefaults
{
    [[NSUserDefaults standardUserDefaults] objectForKey:kSocializerAuthDict];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSocializerAuthDict];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _authorizedAnySocial = self.socialUserIdFromDefaults ? YES : NO;
    NSLog(@"did remove Auth data from userDefaults? %@",![[NSUserDefaults standardUserDefaults] objectForKey:kSocializerAuthDict] ? @"YES":@"NO");
}
@end
