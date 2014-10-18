//
//  StockDatabaseAppDelegate.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/7/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "StockDatabaseAppDelegate.h"
#import "PortfoliosStore.h"
#import "YQL_Server.h"
#import "EntryScreenViewController.h"
#import "iOSVersionCheck.h"
#import "Globals.h"
#import "TestFlight.h"

@implementation StockDatabaseAppDelegate
@synthesize session;
extern CFAbsoluteTime StartTime;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7) {
        [[iOSVersionCheck sharedSingleton] setIsiOS7:TRUE];
    } else {
        [[iOSVersionCheck sharedSingleton] setIsiOS7:FALSE];
    }
    
    EntryScreenViewController *entryViewController = [[EntryScreenViewController alloc] init];
        // Create an instance of a UINavigationController
    // its stack contains only itemsViewController
    UINavigationController *navController = [[UINavigationController alloc]
                                             initWithRootViewController:entryViewController];
    // Place navigation controller's view in the window hierarchy
    [[self window] setRootViewController:navController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    if ([[iOSVersionCheck sharedSingleton] isiOS7]) {
        navController.navigationBar.translucent = NO;
        self.window.tintColor = [Globals kiwi_medBlueColor];
         navController.navigationBar.barTintColor = [Globals kiwi_lightBlueColor];
    }
    [[UINavigationBar appearance] setTintColor:[Globals kiwi_medBlueColor]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Launched in %f seconds",(CFAbsoluteTimeGetCurrent() - StartTime));
        
        [TestFlight takeOff:@"80a4654d-107c-48d7-b37a-3ca2718b0109"];
    });
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    BOOL success = [[PortfoliosStore sharedStore] saveChanges];
    if (success) {
//        NSLog(@"Logged all stocks and portfolios");
    } else {
        NSLog(@"Could not save any stocks/portfolios");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end

