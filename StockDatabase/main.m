//
//  main.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/7/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Globals.h"

#import "StockDatabaseAppDelegate.h"
CFAbsoluteTime StartTime = 0.0;

int main(int argc, char *argv[])
{
    @autoreleasepool {
        StartTime = CFAbsoluteTimeGetCurrent();
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([StockDatabaseAppDelegate class]));
    }
}
