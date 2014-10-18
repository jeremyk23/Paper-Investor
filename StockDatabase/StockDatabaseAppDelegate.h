//
//  StockDatabaseAppDelegate.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/7/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YOSSocial.h"

@interface StockDatabaseAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) YOSSession *session;


//-(void)sendRequests;
//- (void)requestDidFinishLoading:(YOSResponseData *)data;

@end
