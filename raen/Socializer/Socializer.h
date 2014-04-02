//
//  Socializer.h
//  raenapp
//
//  Created by Alexey Ivanov on 18.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocializerDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>

extern NSString *kVkontakteIdentifier;
extern NSString *kGoogleIdentifier;
extern NSString *kTwitterIdentifier;
extern NSString *kFacebookIdentifier;

@interface Socializer : NSObject
@property (nonatomic,strong)  FBSession *fbSession;
@property (nonatomic,strong)  GPPSignIn *googleSignIn;

@property (weak, nonatomic) id<SocializerDelegate> delegate;
@property (readonly,getter = isAuthorizedViaSocial) BOOL AuthorizedViaSocial;
@property (nonatomic,strong) NSString *socialAccessToken;
@property (nonatomic,strong) NSString *socialUserId;
@property (nonatomic,strong) NSString *socialUsername;
@property (nonatomic,strong) NSString *socialUserEmail;

-(void)loginVK;
-(void)loginTwitter;
-(void)loginFacebook;
-(void)loginGoogle;

-(void)logOutVK;
-(void)logOutFacebook;
-(void)logOutGoogle;
@end
