//
//  DateViewController.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/16/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "DateViewController.h"
#import "StockItem.h"

@implementation DateViewController
@synthesize item;

-(void)setItem:(StockItem *)i
{
    item = i;
    [[self navigationItem] setTitle:[item stockName]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)changeItemDate:(id)sender
{
    NSDate *date = [dateWheel date];
    NSTimeInterval t = [date timeIntervalSinceDate:date];
    [item setDateCreated: t];

    
//   NSDateFormatter *dateString = [[NSDateFormatter alloc] init];
//   [dateString setDateStyle:NSDateFormatterShortStyle];
}

@end
