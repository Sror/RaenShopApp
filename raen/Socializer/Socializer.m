//
//  Socializer.m
//  raenapp
//
//  Created by Alexey Ivanov on 18.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import "Socializer.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#import "VKSdk.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

#define kVKAppID @"4237186"
#define kGoogleClientID @"231217279677-ebftkbl3ad5jbhdr1ha7dilcm2otvpil.apps.googleusercontent.com"
#define kGoogleClientSecret @"vGLokxZqDzF5HgIpllGl0Hao"
#define kShouldSaveInKeychainKey  @"shouldSaveInKeychain"
#define kKeychainItemName  @"OAuth raenshopapp: Google+"


NSString *kVkontakteIdentifier = @"Vkontakte";
NSString *kGoogleIdentifier = @"Google";
NSString *kTwitterIdentifier = @"Twitter";
NSString *kFacebookIdentifier = @"Facebook";

@interface Socializer () <VKSdkDelegate,GPPSignInDelegate>{
    int mNetworkActivityCounter;
}

@end
@implementation Socializer



-(FBSession *)fbSession{
    NSLog(@"fbSession initialization");
    if (_fbSession == nil) {
        _fbSession = [[FBSession alloc] initWithPermissions:@[@"basic_info", @"email", @"user_likes"] ];
        NSLog(@"is fbSession open ? %@",_fbSession.isOpen ? @"YES":@"NO");
    }
    return _fbSession;
}
-(GPPSignIn *)googleSignIn{
    NSLog(@"googleSignIn initialization");
    if (_googleSignIn==nil) {
        NSLog(@"googleSignIn set properties");
        _googleSignIn = [GPPSignIn sharedInstance];
        _googleSignIn.shouldFetchGooglePlusUser = YES;
        _googleSignIn.shouldFetchGoogleUserEmail = YES;
        _googleSignIn.shouldFetchGoogleUserID = YES;
        
        _googleSignIn.clientID = kGoogleClientID;
        _googleSignIn.scopes = @[kGTLAuthScopePlusLogin];
        
        // Optional: declare signIn.actions, see "app activities"
        _googleSignIn.delegate = self;
    }
    return _googleSignIn;
}


-(void)loginVK{
    NSLog(@"logining VK.com in _socializer");
    [VKSdk initializeWithDelegate:self andAppId:kVKAppID];
    NSLog(@"is auth in VK.com ? %@",[VKSdk wakeUpSession] ? @"YES":@"NO");
    if ([VKSdk wakeUpSession])
    {
        _socialAccessToken = [VKSdk getAccessToken].accessToken;
        _socialUserId = [VKSdk getAccessToken].userId;
        _AuthorizedViaSocial = YES;
        [self vkUserinfo];
    }else{
        NSArray *scope = @[VK_PER_FRIENDS,VK_PER_WALL,VK_PER_PHOTOS,VK_PER_NOHTTPS];
        [VKSdk authorize:scope revokeAccess:YES];
    }
}

-(void)loginFacebook{
    NSLog(@"socialiser loggining facebook");
    [self.fbSession openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        NSLog(@"error %@",error);
        if (!error) {
            _AuthorizedViaSocial = [_fbSession isOpen];
            if (_AuthorizedViaSocial) {
                _socialAccessToken = _fbSession.accessTokenData.accessToken;
                [self fbUserInfo];
                [self.delegate authorizedViaFaceBook];
            }
        }
    }];
}
-(void)loginTwitter{
    
}
-(void)loginGoogle{
    NSLog(@"singing in Google");
    [self.googleSignIn authenticate];
}

#pragma mark --- logout methods
-(void)logOutVK{
    NSLog(@"logOutVK");
    [VKSdk forceLogout];
    _AuthorizedViaSocial = [VKSdk isLoggedIn];
    NSLog(@"_AuthorizedViaSocial after log out vkontake %@",_AuthorizedViaSocial?@"YES":@"NO");
    _socialUserId = nil;
    _socialAccessToken = nil;
    _socialUserEmail = nil;
    _socialUsername = nil;
}
-(void)logOutFacebook{
    NSLog(@"logOutFacebook");
    // if a user logs out explicitly, we delete any cached token information, and next
    // time they run the applicaiton they will be presented with log in UX again; most
    // users will simply close the app or switch away, without logging out; this will
    // cause the implicit cached-token login to occur on next launch of the application
    [_fbSession closeAndClearTokenInformation];
    _socialUserId = nil;
    _socialAccessToken = nil;
    _socialUserEmail = nil;
    _socialUsername = nil;
    _AuthorizedViaSocial = [_fbSession isOpen];
     NSLog(@"_fbSession isOpen? %@",_AuthorizedViaSocial ? @"YES":@"NO");
}
-(void)logOutGoogle{
    NSLog(@"logOutGoogle");
    [[GPPSignIn sharedInstance] signOut];
    _AuthorizedViaSocial = [[GPPSignIn sharedInstance].authentication canAuthorize];
    _socialUserId = nil;
    _socialAccessToken = nil;
    _socialUserEmail = nil;
    _socialUsername = nil;
     NSLog(@"_googleAuth isOpen? %@",_AuthorizedViaSocial ? @"YES":@"NO");
}

#pragma mark - VKDelegate methods
-(void)vkSdkAcceptedUserToken:(VKAccessToken *)token{
    NSLog(@"vkSdkAcceptedUserToken %@",token);
    _socialAccessToken = token.accessToken;
    _socialUserId = token.userId;
    _AuthorizedViaSocial = YES;
    [self vkUserinfo];
}
-(void)vkSdkNeedCaptchaEnter:(VKError *)captchaError{
    NSLog(@"vkSdkNeedCaptchaEnter %@",captchaError);
    VKCaptchaViewController * vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self];
}
-(void)vkSdkReceivedNewToken:(VKAccessToken *)newToken{
    NSLog(@"vkSdkReceivedNewToken %@",newToken);
    _AuthorizedViaSocial = YES;
    _socialAccessToken = newToken.accessToken;
    _socialUserId = newToken.userId;
    [self vkUserinfo];

}
-(void)vkSdkRenewedToken:(VKAccessToken *)newToken{
    NSLog(@"vkSdkRenewedToken %@",newToken);
    _AuthorizedViaSocial = YES;
    _socialAccessToken = newToken.accessToken;
    _socialUserId = newToken.userId;
    [self vkUserinfo];
}
-(void)vkSdkShouldPresentViewController:(UIViewController *)controller{
    NSLog(@"vkSdkShouldPresentViewController");
}
-(void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken{
    NSLog(@"vkSdkTokenHasExpired %@",expiredToken);
    _AuthorizedViaSocial = NO;
    //[self loginVK];
    NSArray *scope = @[VK_PER_FRIENDS,VK_PER_WALL,VK_PER_PHOTOS,VK_PER_NOHTTPS];
    [VKSdk authorize:scope revokeAccess:YES];
}
-(void)vkSdkUserDeniedAccess:(VKError *)authorizationError{
    NSLog(@"vkSdkUserDeniedAccess %@",authorizationError);
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access denied" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
}

#pragma mark - VK.com methods
-(void)vkUserinfo{
    NSLog(@"vkUserinfo");
    if (_AuthorizedViaSocial==YES)
    {
        VKRequest *userInfoRequest = [VKApi users].get;
        [userInfoRequest executeWithResultBlock:^(VKResponse *response) {
            NSArray *json = response.json;
            NSLog(@"response json from vkUserInfo method \n%@",json);
            if ([json.firstObject isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *jsonDict = json.firstObject;
                _socialUsername = [NSString stringWithFormat:@"%@ %@",jsonDict[@"first_name"],jsonDict[@"last_name"]];
                _socialUserId = [NSString stringWithFormat:@"%@",jsonDict[@"id"]];
                _AuthorizedViaSocial = YES;
                [self.delegate authorizedViaVK];
            }
        } errorBlock:^(NSError *error) {
            NSLog(@"error to get user info %@",error.description);
            _AuthorizedViaSocial = NO;
        }];
    }else{
        //NOT AUTH VIA SOCIAL
        NSLog(@"error: can't get vk user info , cause _AuthorizedViaSocial == NO");
    }
}

#pragma mark - Facebook 
-(void)fbUserInfo{
    NSLog(@"getting facebook user info");
    if ([_fbSession isOpen]) {
        [FBSession setActiveSession:_fbSession];
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                NSDictionary<FBGraphUser> *my = (NSDictionary<FBGraphUser> *) result;
                NSLog(@"My dictionary: %@", my);
                _socialUsername = [NSString stringWithFormat:@"%@ %@",my.first_name, my.last_name];
                _socialUserId = my.id;
                _socialUserEmail = result[@"email"];
                
                [self.delegate authorizedViaFaceBook];
            }else{
                NSLog(@"error to get facebook user info %@",error.description);
            }
        }];
    }
}
#pragma mark - Google sign In Delegate methods 
-(void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error{
     NSLog(@"Finished Google Auth with received error %@ and auth object %@",error, auth);
    if (!error) {
        _socialAccessToken = auth.accessToken;
        _socialUserEmail = auth.userEmail;
        _socialUserId = _googleSignIn.userID;
#warning how to get google + user name ?
        _socialUsername = nil;
        _AuthorizedViaSocial = [auth canAuthorize];
        if (_AuthorizedViaSocial) {
            [self.delegate authorizedViaGoogle];
        }
    }
}
@end
