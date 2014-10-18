//
//  Globals.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 8/2/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Globals : NSObject

+(void)formatForiOS7:(UIViewController *)theViewController;

+ (UIColor *)stockGreenColor;
+ (UIColor *)stockRedColor;
+ (UIColor *)kiwi_greenColor;
+ (UIColor *)kiwi_whiteColor;
+ (UIColor *)kiwi_darkBlueColor;
+ (UIColor *)kiwi_medBlueColor;
+ (UIColor *)kiwi_lightBlueColor;

+(NSString *)returnDateRepresentation:(NSTimeInterval)time;

+(NSString *)formatFloat:(float) number;
+(NSString *)formatCurrencyFloat:(float) number;
+(NSString *)formatDouble:(double) number;
+(NSString *)formatCurrencyDouble:(double) number;

+(int)formatStringToInt:(NSString *)stringNumber;
+(float)formatStringToFloat:(NSString *)stringNumber;

+(void)fadeInUIView:(UIView *)view;
+(void)fadeOutUIView:(UIView *)view;
+(void)greyOutView:(UIView *)fadeView;
+(void)greyInView:(UIView *)fadeView;


+(UIActivityIndicatorView *)startActivityIndicator:(UIView *)viewToAnimate;

+(void)sizeImage:(UIView *)theView : (NSString *)imageName;



@end
