//
//  Socializer.h
//  Socializer
//
//  Created by Alexey Ivanov on 09.04.14.
//  Copyright (c) 2014 Alexey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VKSdk.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>

#import <Accounts/Accounts.h>
#import "TWAPIManager.h"

extern NSString* kVKAppId;
extern NSString* kFacebookAppID;

//NSUserDefault keys
extern NSString* kSocializerAuthDict;
extern NSString* kSocializerRaenAPIToken;
extern NSString* kSocializerSocialAccessToken;
extern NSString* kSocializerSocialIdentifier;
extern NSString* kSocializerSocialUserID;
extern NSString* kSocializerSocialUserFullName;
extern NSString* kSocializerSocialUserEmail;
extern NSString* kUserPhone;

//Social Identifiers
extern NSString *kVkontakteIdentifier;
extern NSString *kGoogleIdentifier;
extern NSString *kTwitterIdentifier;
extern NSString *kFacebookIdentifier;


@protocol SocializerDelegate <NSObject>

- (void)shouldShowVCCaptchaVC:(VKCaptchaViewController*)viewController;
- (void)shouldPresentVKViewController:(UIViewController*)controller;
- (void)shouldPresentGoogleAuthViewController:(GTMOAuth2ViewControllerTouch*)controller;
- (void)successfullyAuthorizedToSocialNetwork;
 
- (void)successLogout;
- (void)failureAuthorization;
@end


@interface Socializer : NSObject
@property (weak, nonatomic) id <SocializerDelegate> delegate;

@property (getter = isAuthorizedAnySocial) BOOL authorizedAnySocial;

@property (nonatomic,strong) NSString *socialAccessToken;
@property (nonatomic,strong) NSString *socialUserId;
@property (nonatomic,strong) NSString *socialUsername;
@property (nonatomic,strong) NSString *socialUserEmail;
@property (nonatomic,strong) NSString *socialIdentificator;
@property (nonatomic,strong) NSString *raenAPIToken;
@property (nonatomic,strong) NSString *userPhone;

@property (nonatomic,strong)  FBSession *fbSession;

@property (nonatomic,strong) ACAccountStore *accountStore;
@property (nonatomic,strong) ACAccount *twitterAccount;
@property (nonatomic,strong) TWAPIManager *twitterAPIManager;
@property (nonatomic,strong) NSArray* twitterAccounts;

@property ACAccount* facebookAccount;

//Singleton
+ (Socializer*)sharedManager;

//Log IN methods
-(void)loginVK;
-(void)loginTwitterAccountAtIndex:(NSInteger)index;;
-(void)loginFacebook;
-(void)loginGoogle;

//Log OUT methods
-(void)logOutFromCurrentSocial;
//twitter
- (void)obtainAccessToAccountsWithBlock:(void (^)(BOOL))block;

//Local storage manager
- (NSString*)socialTokenFromDefaults;
- (NSString*)raenAPITokenFromDefaults;
- (NSString*)socialIdFromDefaults;
- (NSString*)socialUserEmailFromDefaults;
- (NSString*)socialUserNameFromDefaults;
- (NSString*)socialUserIdFromDefaults;

- (void)saveAuthUserDataToDefaults;
- (void)removeAuthDataFromDefaults;

@end
