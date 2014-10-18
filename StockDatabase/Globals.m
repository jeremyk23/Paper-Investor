//
//  Globals.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 8/2/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "Globals.h"
#import "UIColor+Custom_Color.h"
#import "StockDatabaseAppDelegate.h"
#import "iOSVersionCheck.h"

@implementation Globals

+(void)formatForiOS7:(UIViewController *)theViewController {
    if ([[iOSVersionCheck sharedSingleton] isiOS7]) {
        theViewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

+(UIColor *)stockGreenColor {
    return [UIColor stockGreenColor];
}

+(UIColor *)stockRedColor {
    return [UIColor stockRedColor];
}

+ (UIColor *)kiwi_greenColor {
    return [UIColor kiwi_greenColor];
}

+ (UIColor *)kiwi_whiteColor {
    return [UIColor kiwi_whiteColor];
}

+ (UIColor *)kiwi_darkBlueColor {
    return [UIColor kiwi_darkBlueColor];
}

+ (UIColor *)kiwi_medBlueColor {
    return [UIColor kiwi_medBlueColor];
}

+ (UIColor *)kiwi_lightBlueColor {
    return [UIColor kiwi_lightBlueColor];
}

+(NSString *)returnDateRepresentation: (NSTimeInterval)time
{
    //USING CORE DATA version of date
    //convert time interval to NSDate
    NSDate *date = [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    NSString *stringDate = [formatter stringFromDate:date];
    return stringDate;
}

+(NSString *)formatFloat:(float) number
{
    NSNumber *floatNumber = [NSNumber numberWithFloat:number];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setLenient:YES];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator: YES];
    [formatter setGroupingSize:3];
    [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    NSString *numberString = [formatter stringFromNumber:floatNumber];
    return numberString;
}

+(NSString *)formatCurrencyFloat:(float) number
{
    NSNumber *floatNumber = [NSNumber numberWithFloat:number];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setLenient:YES];
    [formatter setNegativePrefix:@"-$"];
    [formatter setNegativeSuffix:@""];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setUsesGroupingSeparator: YES];
    [formatter setGroupingSize:3];
    [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    NSString *numberString = [formatter stringFromNumber:floatNumber];
    return numberString;
}

+(NSString *)formatDouble:(double) number
{
    NSNumber *doubleNumber = [NSNumber numberWithDouble:number];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    [formatter setLenient:YES];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setUsesGroupingSeparator: YES];
    [formatter setGroupingSize:3];
    [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    NSString *numberString = [formatter stringFromNumber:doubleNumber];
    return numberString;
}

+(NSString *)formatCurrencyDouble:(double) number
{
    NSNumber *doubleNumber = [NSNumber numberWithDouble:number];
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    [formatter setLenient:YES];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [formatter setUsesGroupingSeparator: YES];
    [formatter setGroupingSize:3];
    [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
    NSString *numberString = [formatter stringFromNumber:doubleNumber];
    return numberString;
}

+(int)formatStringToInt:(NSString *)stringNumber
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setMaximumFractionDigits:0];
    [formatter setLenient:YES];
    NSNumber *numberFormatted = [formatter numberFromString:stringNumber];
    int intNumber = [numberFormatted intValue];
    return intNumber;
}

+(float)formatStringToFloat:(NSString *)stringNumber
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setRoundingMode:NSNumberFormatterRoundDown];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setLenient:YES];
    NSNumber *numberFormatted = [formatter numberFromString:stringNumber];
    float floatNumber = [numberFormatted floatValue];
    return floatNumber;
}

+ (void)fadeInUIView:(UIView *)view
{
    view.alpha = 0;
    view.hidden = NO;
    [UIView animateWithDuration:0.6 animations:^{
        view.alpha = 1;
    }];
}

+ (void)fadeOutUIView:(UIView *)view
{
    [UIView animateWithDuration:0.6 animations:^{
        view.alpha = 0;
    } completion: ^(BOOL finished) {
        view.hidden = YES;
    }];
}



+(void)greyOutView:(UIView *)fadeView
{
    [UIView animateWithDuration:0.6 animations:^{
        fadeView.alpha = 0.5f;
    }];
}

+(void)greyInView:(UIView *)fadeView
{
    [UIView animateWithDuration:0.6 animations:^{
        fadeView.alpha = 1.0f;
    }];
}
     

+(void)sizeImage:(UIView *)theView : (NSString *)imageName {
    UIGraphicsBeginImageContext(theView.frame.size);
    [[UIImage imageNamed:imageName] drawInRect:theView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    theView.backgroundColor = [UIColor colorWithPatternImage:image];
}

+(UIActivityIndicatorView *)startActivityIndicator:(UIView *)viewToAnimate
{
    //activity indicator initializer
    UIActivityIndicatorView *activityIndicator =  [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    CGRect mainWindow = [[UIScreen mainScreen] bounds];
    activityIndicator.center = CGPointMake((mainWindow.size.width/2), (mainWindow.size.height/2));
    activityIndicator.hidesWhenStopped = YES;
    [viewToAnimate addSubview:activityIndicator];
    [viewToAnimate bringSubviewToFront:activityIndicator];
    [activityIndicator startAnimating];
    
    return activityIndicator;
}

@end
