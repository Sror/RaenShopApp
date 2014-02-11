//
//  RaenAPI.h
//  raenapp
//
//  Created by Alexey Ivanov on 10.02.14.
//  Copyright (c) 2014 Aleksey Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>


extern  NSString *RaenAPIGotBikes;
extern  NSString *RaenAPIGotCategories;
extern  NSString *RaenAPIGotGuards;

@interface RaenAPI : NSObject
@property (nonatomic,readonly,getter = isReady) BOOL ready;
@property (nonatomic,strong) NSArray *bikes;
@property (nonatomic,strong) NSArray *categories;
@property (nonatomic,strong) NSArray *guards;

@property (nonatomic,strong) NSURLSession *session;
@property (nonatomic,strong) NSURLSessionDataTask *dataTask;

+(RaenAPI*)sharedInstance;

-(void)updateBikes;
-(void)updateCategories;
-(void)updateGuards;

@end
