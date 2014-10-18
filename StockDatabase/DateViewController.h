//
//  DateViewController.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/16/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StockItem;
@interface DateViewController : UIViewController
{
    __weak IBOutlet UIDatePicker *dateWheel;
}
-(IBAction)changeItemDate:(id)sender;

@property(nonatomic, strong) StockItem *item;
@end
