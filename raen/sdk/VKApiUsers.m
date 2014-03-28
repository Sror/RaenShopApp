//
//  VKApiUsers.m
//
//  Copyright (c) 2013 VK.com
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "VKApiUsers.h"
#import "VKUsersArray.h"
@implementation VKApiUsers
#pragma mark get
- (VKRequest *)get {
	return [self get:nil];
}

- (VKRequest *)get:(NSDictionary *)params {
	return [self prepareRequestWithMethodName:@"get" andParameters:params andHttpMethod:@"GET" andClassOfModel:[VKUsersArray class]];
}

#pragma mark search
- (VKRequest *)search:(NSDictionary *)params {
	return [self prepareRequestWithMethodName:@"search" andParameters:params andHttpMethod:@"GET" andClassOfModel:[VKUsersArray class]];
}

#pragma mark isAppUser
- (VKRequest *)isAppUser {
	return [self prepareRequestWithMethodName:@"isAppUser" andParameters:nil];
}

- (VKRequest *)isAppUser:(NSInteger)userID {
	return [self prepareRequestWithMethodName:@"isAppUser" andParameters:@{ VK_API_USER_ID : @(userID) }];
}

#pragma mark subscriptions
- (VKRequest *)getSubscriptions {
	return [self getSubscriptions:nil];
}

- (VKRequest *)getSubscriptions:(NSDictionary *)params {
	return [self prepareRequestWithMethodName:@"getSubscriptions" andParameters:params];
}

#pragma mark followers
- (VKRequest *)getFollowers {
	return [self getFollowers:nil];
}

- (VKRequest *)getFollowers:(NSDictionary *)params {
	return [self prepareRequestWithMethodName:@"getFollowers" andParameters:params andHttpMethod:@"GET" andClassOfModel:[VKUsersArray class]];
}

@end
