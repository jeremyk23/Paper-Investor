//
//  iOSVersionCheck.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 9/28/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iOSVersionCheck : NSObject

+ (iOSVersionCheck *)sharedSingleton;

@property BOOL isiOS7;
@end
