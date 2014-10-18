//
//  iOSVersionCheck.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 9/28/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "iOSVersionCheck.h"

@implementation iOSVersionCheck
@synthesize isiOS7;

+ (iOSVersionCheck *)sharedSingleton
{
    static iOSVersionCheck *sharedSingleton = nil;
    if (!sharedSingleton)
        sharedSingleton = [[super allocWithZone:nil] init];
    return sharedSingleton;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return  [self sharedSingleton];
}


@end
