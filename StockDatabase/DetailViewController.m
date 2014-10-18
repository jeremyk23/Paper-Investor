//
//  DetailViewController.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/11/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//


#import "DetailViewController.h"
#import "StockItem.h"
#import "YQL_Server.h"
#import "UserPortfolio.h"
#import "Globals.h"

#define NO_IMAGE @"False"
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == 568 )

@implementation DetailViewController
@synthesize stock, portfolio, didTrade, isValidStock, cameBackFromBackground, statusCode, stockChartImages;

//want user to tap screen and enter info. This view that they will use is the DetailViewController
//needs four subviews, each for the details of the stock. To make these editable by user, use outlets

-(void)setStockAndPortfolio:(StockItem *)s : (UserPortfolio *)port
{
    stock = s;
    stock.portfolioString= port.title;
    portfolio = port;
    [[self navigationItem] setTitle:[stock stockName]];

}
-(id) init {
    self = [super init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:NULL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:NULL];
    self.cameBackFromBackground = FALSE;
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Globals formatForiOS7:self];
    
    stockChartImages = [[NSMutableArray alloc] initWithCapacity:timeSelector.numberOfSegments];
    
    [[self view] setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    
    self.didTrade = FALSE;
    
    [self formatUIComponents];
    
    [self fillArrayWithEmptyObjects];
    
    [timeSelector setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                 [UIFont fontWithName:@"Futura" size:14.0f], UITextAttributeFont,
                                                                 nil] forState:UIControlStateNormal];
    timeFrameValues = [[NSArray alloc] initWithObjects:@"1d", @"1w", @"1m", @"6m", @"1y", @"2y", nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    //set background image
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenBG_2.png"]];
    [self.view addSubview:backgroundView];
    backgroundView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view sendSubviewToBack:backgroundView];
    
    sharesField.delegate = self;
    
    [super viewWillAppear:animated];
    
    //hide buttons to be used after user enters info
    tradeButton.hidden = YES;
    sharesField.hidden = YES;
    
    //show current portfolio funds
    [portfolioFundsField setText:[NSString stringWithFormat:@"Portfolio Funds: $%@", [Globals formatFloat:[portfolio.currentFunds floatValue]]]];
}
-(void)viewWillDisappear:(BOOL)animated
{
    //if screen is exiting becuase user hit the back button instead of trade, delete the stock.
    [self checkToDeleteStock];
    [super viewWillDisappear:animated]; //the superclass does stuff to so always call it
    //clear first responder
    [[self view] endEditing:YES];
        
}

-(void) applicationWillResignActive:(UIApplication *)application {
    [self checkToDeleteStock];
}
-(void) applicationDidBecomeActive:(UIApplication *)application {
    stock = [portfolio createStock];
    self.cameBackFromBackground = TRUE;
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == sharesField){
        //if there are no problems with their number (returns true), proceed to formatShares entry
        if ([self errorCheckShares: textField]) {
            [self formatSharesEntry:textField];
        }
    }
    if (textField == nameField) {
        //if they enter nothing, do nothing
        if ([nameField text].length == 0) {
            [textField resignFirstResponder];
            self.isValidStock = FALSE;
            [self disableTradeButton];
        } //else obtain stock info
        else {
            [self fillArrayWithEmptyObjects];
            //pinging yahoo's server first determines if it's a valid ticker symbol
            [stock setStockName:[nameField text]];
            activityIndicator = [Globals startActivityIndicator:self.view];
            //set stock info
            self.stockPrice = [[YQL_Server sharedServer] returnStockInfo:stock :@"LastTradePriceOnly"];
            stock.companyName = [[YQL_Server sharedServer] returnStockInfo:stock :@"Name"];
            
            
            //-----------------CODE TO DETERMINE IF THIS IS A REAL STOCK-----------------------------
            //if they have already entered a number in the shares field, refresh calculations. (Happens when they change their mind on what stock they want to buy).
            if ([Globals formatStringToInt:[sharesField text]]) {
                [self formatSharesEntry:sharesField];
            }
            //if it is an invalid ticker symbol display alert
            if ([self.stockPrice isEqualToString:@"0.00"])
            {
                [activityIndicator stopAnimating];
                [textField resignFirstResponder];
                self.isValidStock = FALSE;
                //disable trade button if visible
                if (tradeButton.hidden == NO) {
                    [self disableTradeButton];
                }
                [self displayInvalidStockAlert];
            }
            //-------------------------------------------------------------------------------\\
            //Everything is good. Show current price and fade in enter shares option. And display chart
            else {
                [self getChart];
                [textField setText: [[textField text] uppercaseString]];
                [textField resignFirstResponder];
                [self enableTradeButton];
                self.isValidStock = TRUE;
                
                [currentPriceField setText:self.stockPrice];
                [currentPriceField setTextColor:[Globals kiwi_medBlueColor]];
                
                //this only happens first time. Using shareLabel as test is just a random pick of these fields which should all fade in and out together.
                if (shareLabel.hidden == YES) {
                    [Globals fadeInUIView:sharesField];
                    [Globals fadeInUIView:stockPriceLabel];
                    [Globals fadeInUIView:shareLabel];
                    [Globals fadeInUIView:currentPriceField];
                    [Globals fadeInUIView:timeSelector];
                }
            }
        }
    }
}

-(void)getChart
{
    if ([stockChartImages[timeSelector.selectedSegmentIndex] isEqual:NO_IMAGE]) {
        int timeFrameIndex = timeSelector.selectedSegmentIndex;
        NSString *timeString = [NSString stringWithFormat:@"%@",timeFrameValues[timeFrameIndex]];
        NSString *urlString = [NSString stringWithFormat:@"http://chart.finance.yahoo.com/z?s=%@&t=%@",stock.stockName,timeString];
        [self loadImageFromURL:[NSURL URLWithString:urlString]];
    } else {
        chartImage.image = stockChartImages[timeSelector.selectedSegmentIndex];
    }
}

- (IBAction)changeTimeFrame:(id)sender {
    chartPeriodLabel.text = [self getTimePeriodString];
    [self getChart];
}

- (IBAction)executeTrade:(id)sender {
    if ([self errorCheckStockInfo] == FALSE) {
        //do nothing, errorCheckStockInfo displays relavant alerts
    } else {
        //if they entered the stock info, hit the home button and come back to the screen, this will refresh all stock info.
        if (cameBackFromBackground) {
            [stock setStockName:[nameField text]];
            activityIndicator = [Globals startActivityIndicator:self.view];
            self.stockPrice = [[YQL_Server sharedServer] returnStockInfo:stock :@"LastTradePriceOnly"];
            stock.companyName = [[YQL_Server sharedServer] returnStockInfo:stock :@"Name"];
            cameBackFromBackground = FALSE;
        }
    [activityIndicator stopAnimating];
    [stock setPricePaidFormatted:self.stockPrice];
    
    //"Save" changes to editing
    [stock setStockName:[nameField text]];
    [stock setPricePaid: [self.stockPrice floatValue]];
    
    //set to last trading price
    stock.currentPrice = [self.stockPrice floatValue];
    [stock setCurrentPriceFormatted:[stock formatFloat:stock.currentPrice]];
    
    [stock setPercentChange:[stock calculatePercentChange]];
    NSNumber *stuffLeft = [NSNumber numberWithFloat:self.fundsLeft];
    portfolio.currentFunds = stuffLeft;
    
    stock.sharesBought = [[sharesField text] intValue];
    
    self.didTrade = TRUE;
    [[self navigationController] popViewControllerAnimated:YES];
    }

}

- (BOOL)errorCheckShares:(UITextField *)field {
    //if they enter an invalid or negative number, alert them
    int sharesEntered = [Globals formatStringToInt:[field text]];
    if (!sharesEntered || sharesEntered <= 0) {
        [self displayInvalidNumberAlert];
        if (recieptLabel.hidden == NO) {
            [Globals fadeOutUIView:tradeButton];
            [Globals fadeOutUIView:recieptLabel];
            [Globals fadeOutUIView:fundsLeftLabel];
        }
        return FALSE;
    } else {
        return TRUE;
    }
}

- (void)formatSharesEntry:(UITextField *)textField
{
    //if user hasn't entered a stock yet
    if (self.stockPrice == nil) {
        [textField resignFirstResponder];
    }
    //if there is a valid last stock price, use it
    if (self.stockPrice) {
        float price = [self.stockPrice floatValue] * [Globals formatStringToInt:[textField text]];
        NSString *priceString = [Globals formatFloat:price];
        [recieptLabel setTextColor:[Globals kiwi_darkBlueColor]];
        [recieptLabel setText: [NSString stringWithFormat:@"Total Cost: $%@", priceString]];
        [Globals fadeInUIView:fundsLeftLabel];
        [Globals fadeInUIView:recieptLabel];
        self.fundsLeft = [portfolio.currentFunds doubleValue] - price;
        
        //if they don't have enough money in their portfolio
        if (self.fundsLeft < 0) {
            NSString *displayNumber = [Globals formatFloat:self.fundsLeft];
            fundsLeftLabel.textColor = [Globals stockRedColor];
            [fundsLeftLabel setText:[NSString stringWithFormat:@"Insufficient Funds: $%@", displayNumber]];
            [textField resignFirstResponder];
            tradeButton.hidden = YES;
        }
        //if they do, also display tradeButton
        else if (self.fundsLeft >= 0) {
            NSString *displayNumber = [Globals formatFloat:self.fundsLeft];
            fundsLeftLabel.textColor = [Globals kiwi_darkBlueColor];
            [fundsLeftLabel setText:[NSString stringWithFormat:@"Funds Left: $%@", displayNumber]];
            [textField resignFirstResponder];
            
            [Globals fadeInUIView:tradeButton];
            [self setChartLabelFrame];
        }
        
    }
}

//Function is a last resort to prevent user from buying an invalid stock or share amount.
- (BOOL)errorCheckStockInfo
{
    //if stock field is empty
    if ([nameField text].length == 0) {
        [self displayInvalidStockAlert];
        return FALSE;
    } //else obtain stock info
    else if (self.isValidStock == FALSE) {
        [self displayInvalidStockAlert];
        return FALSE;
    }
    return TRUE;
}

- (void)displayInvalidStockAlert
    {
        UIAlertView *tickerAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Ticker Symbol" message:@"The ticker symbol you entered is invalid." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [tickerAlert show];
    }
- (void)displayInvalidNumberAlert
{
    UIAlertView *numberAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Number" message:@"The number you entered is invalid. Make sure you use only whole numbers." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [numberAlert show];
}

- (void)loadImageFromURL:(NSURL *)URL
{
    NSURLRequest *request = [NSURLRequest requestWithURL:URL cachePolicy:NSURLCacheStorageAllowed timeoutInterval:8.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSURLResponse *)response {
    if ([response isKindOfClass: [NSHTTPURLResponse class]]) {
        statusCode = [(NSHTTPURLResponse*) response statusCode];
        /* HTTP Status Codes
         200 OK
         400 Bad Request
         401 Unauthorized (bad username or password)
         403 Forbidden
         404 Not Found
         502 Bad Gateway
         503 Service Unavailable
         */
    }
    if (chartData == nil) {
        //create NSMutableData to hold the download data
        chartData = [[NSMutableData alloc] initWithCapacity:2048];
    }
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData
{
    
    [chartData appendData:incrementalData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    //data now has the entire image data
    [activityIndicator stopAnimating];
    connection = nil;
    
    [stockChartImages replaceObjectAtIndex:timeSelector.selectedSegmentIndex withObject:[UIImage imageWithData:chartData]];
    
    [self displayChartImages];
    
    if (fill) {
        chartImage.contentMode = UIViewContentModeScaleAspectFill;
    } else {
        chartImage.contentMode = UIViewContentModeScaleAspectFill;
    }
    chartData = nil;
}

- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    NSLog(@"error is: xxxxxxxx \n %@", error);
    statusCode = 0; // Status code is not valid with this kind of error, which is typically a timeout or no network error.
    chartData = nil;
}

- (void)displayChartImages
{
    chartImage.image = stockChartImages[timeSelector.selectedSegmentIndex];
    chartPeriodLabel.text = [self getTimePeriodString];
    [self setChartLabelFrame];
    
    //if this is the first time the chart has been displayed, fade in
    if (chartImage.hidden == YES) {
        [Globals fadeInUIView:chartImage];
        [Globals fadeInUIView:chartBorder];
//        [Globals fadeInUIView:chartPeriodLabel];
    }
}

- (void)setChartLabelFrame
{
    CGRect buttonsFrame = timeSelector.frame;
    CGPoint buttonsPoint = CGPointMake(chartBorder.frame.origin.x + 5, (chartBorder.frame.origin.y + chartBorder.frame.size.height) - 35);
    buttonsFrame.origin = buttonsPoint;
    timeSelector.frame = buttonsFrame;
    
    
//    CGRect labelFrame = chartPeriodLabel.frame;
//    CGPoint labelPoint = CGPointMake(chartBorder.frame.origin.x + 5, (chartBorder.frame.origin.y + chartBorder.frame.size.height) - 35);
//    labelFrame.origin = labelPoint;
//    chartPeriodLabel.frame = labelFrame;
}
- (void) disableTradeButton
{
    if (tradeButton.hidden == NO) {
        [Globals greyOutView:tradeButton];
        tradeButton.enabled = NO;
    }
}

- (void)enableTradeButton
{
    if (tradeButton.enabled == NO)
    {
        [Globals greyInView:tradeButton];
        tradeButton.enabled = YES;
    }
}

- (void)checkToDeleteStock {
    if (self.didTrade == FALSE){
        [portfolio removeItem:stock];
    }
}

- (void)formatUIComponents {
    
    if (IS_IPHONE_5) {
        CGFloat bottomOfSharesLabel = shareLabel.frame.origin.y + shareLabel.frame.size.height;
        CGFloat topOfTradeButton = tradeButton.frame.origin.y;
        CGFloat chartImageYPos = ((topOfTradeButton - bottomOfSharesLabel)/2) + 40;
        CGFloat deltaForBorder = chartImageYPos - chartImage.frame.origin.y;
        CGRect chartFrame = chartImage.frame;
        CGPoint chartOrigin = CGPointMake(chartImage.frame.origin.x, chartImageYPos);
        chartFrame.origin = chartOrigin;
        chartImage.frame = chartFrame;
        

        chartBorder.frame = CGRectOffset(chartBorder.frame, 0, deltaForBorder);
    }
    
    //hide UI Components
    timeSelector.hidden = YES;
    stockPriceLabel.hidden = YES;
    shareLabel.hidden = YES;
    chartPeriodLabel.hidden = YES;
    chartImage.hidden = YES;
    chartBorder.hidden = YES;
}

- (void)fillArrayWithEmptyObjects {
    //if they have already entered a valid stock, REPLACE all charts in array with NO_IMAGE
    if (shareLabel.hidden == NO) {
        for (int i = 0; i <= timeSelector.numberOfSegments; i++) {
            [stockChartImages replaceObjectAtIndex:i withObject:NO_IMAGE];
        }
    } else { //This is the first stock they are entering so just add NO_IMAGE strings to the array.
        for (int i = 0; i <= timeSelector.numberOfSegments; i++) {
            [stockChartImages addObject:NO_IMAGE];
        }
    }
}

- (NSString *)getTimePeriodString {
    if (timeSelector.selectedSegmentIndex == 0) { return @"1 Day"; }
    else if (timeSelector.selectedSegmentIndex == 1) { return @"1 Week"; }
    else if (timeSelector.selectedSegmentIndex == 2) { return @"1 Month"; }
    else if (timeSelector.selectedSegmentIndex == 3) { return @"6 Month"; }
    else if (timeSelector.selectedSegmentIndex == 4) { return @"1 Year"; }
    else  { return @"2 Years"; }
}

- (void) animateTextField: (UITextField*)textField up: (BOOL) up
{
    [UIView animateWithDuration:0.3 animations:^{
        shareLabel.frame = CGRectOffset(shareLabel.frame, 0, -10);
        textField.frame = CGRectOffset(textField.frame, 0, -10);
    }];
}

- (void) animateTextField : (UITextField *)textField down: (BOOL) down
{
    [UIView animateWithDuration:0.3 animations:^{
        shareLabel.frame = CGRectOffset(shareLabel.frame, 0, 10);
        textField.frame = CGRectOffset(textField.frame, 0, 10);
    }];
}

@end
