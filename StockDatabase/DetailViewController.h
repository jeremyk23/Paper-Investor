//
//  DetailViewController.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/11/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DateViewController.h"

@class UserPortfolio;
@class StockItem;

@interface DetailViewController : UIViewController <UITextFieldDelegate, NSURLConnectionDelegate, UIApplicationDelegate>
{
    NSArray *timeFrameValues;
    __weak IBOutlet UILabel *portfolioFundsField;
    __weak IBOutlet UILabel *currentPriceField;
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UITextField *sharesField;
    __weak IBOutlet UILabel *recieptLabel;
    __weak IBOutlet UILabel *fundsLeftLabel;
    __weak IBOutlet UIButton *tradeButton;
    __weak IBOutlet UILabel *shareLabel;
    __weak IBOutlet UILabel *stockPriceLabel;
    __weak IBOutlet UIImageView *chartImage;
    __weak IBOutlet UILabel *chartPeriodLabel;
    __weak IBOutlet UISegmentedControl *timeSelector;
    
    __weak IBOutlet UIImageView *chartBorder;
    NSURLConnection *connection;
    
    //stores chart data here as data downloads
    NSMutableData *chartData;
    
    UIActivityIndicatorView *activityIndicator;
    Boolean fill;
}

- (IBAction)changeTimeFrame:(id)sender;
- (IBAction)executeTrade:(id)sender;
- (NSString *)getTimePeriodString;
- (void)setStockAndPortfolio:(StockItem *)s : (UserPortfolio *)port;
- (void)formatSharesEntry:(UITextField *)textField;
- (void)loadImageFromURL:(NSURL *)URL;
- (void)getChart;
- (BOOL)errorCheckShares:(UITextField *)field;
- (BOOL)errorCheckStockInfo;
- (void)displayChartImages;
- (void)setChartLabelFrame;
- (void)displayInvalidStockAlert;
- (void)displayInvalidNumberAlert;
- (void)disableTradeButton;
- (void)enableTradeButton;
- (void)checkToDeleteStock;
- (void)formatUIComponents;
- (void)fillArrayWithEmptyObjects;


@property (nonatomic, strong)StockItem *stock;
@property (nonatomic, strong)UserPortfolio *portfolio;
@property (nonatomic, strong)NSString *stockPrice;
@property (nonatomic, strong) NSMutableArray *stockChartImages;
@property (nonatomic) float fundsLeft;
@property (nonatomic) BOOL didTrade;
@property (nonatomic) BOOL isValidStock;
@property (nonatomic) BOOL cameBackFromBackground;
@property (nonatomic) int statusCode;


@end
