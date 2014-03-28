//
//  SocializerDelegate.h
//  raenapp
//
//  Created by Alexey Ivanov on 19.03.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SocializerDelegate <NSObject>

@optional
- (void)authorizedViaVK;
- (void)authorizedViaFaceBook;

- (void)authorizedViaGoogle;
- (void)pushGoogleLoginVC:(UIViewController*)viewcontroller;
@end
