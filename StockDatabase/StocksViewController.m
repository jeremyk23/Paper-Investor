//
//  StocksViewController.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/30/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "Globals.h"
#import "StocksViewController.h"
#import "StockItem.h"
#import "UserPortfolio.h"
#import "iOSVersionCheck.h"

@interface StocksViewController ()

@end

//center content Table view should be 320 width, 418 height x is 160, y is 246

@implementation StocksViewController
@synthesize stock, portfolio, stockDetailsKeysArray, isiPhone5;

-(void)setStockAndPortfolio:(StockItem *)s : (UserPortfolio *)port
{
    stock = s;
    portfolio = port;
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
    [Globals formatForiOS7:self];
    [self sizeTableViewRows];
    [infoTableView reloadData];

    //load the stocksTableHeaderView.xib
    [[NSBundle mainBundle] loadNibNamed:@"stocksTableHeaderView" owner:self options:nil];
    
    //configure labels
    NSString *purchasedMarketValue = [Globals formatFloat:[stock purchasedMarketValue]];
    [totalFundsLabel setText:[NSString stringWithFormat:@"$%@", purchasedMarketValue]];
    
    NSString *currentMarketValue = [Globals formatFloat:[stock currentMarketValue]];
    [prcntOfPortfolioLabel setText: [NSString stringWithFormat:@"$%@",currentMarketValue]];

    //displays date stock was purchased
    [purchaseDateLabel setText:[NSString stringWithFormat:@"Purchased: %@", [Globals returnDateRepresentation:stock.dateCreated]]];
    
    //stores alphabetically sorted array of keys to use when filling the 
    stockDetailsKeysArray =[[stock.stockDetailsDict allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    [self configureTabBar];
    
#pragma mark TODO - Make sure there's data in the table
//   XXXXXXXXXXXXXXXXXXXXXXXXXXX check there is data stored on the stock
//    if(!stock.stockDetailsDict) {
//        
//    }
}

//UITableView stuff
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self configureTableView];
    
    //display colored stockPercentage on Label
    [self formatGLPercentage:stock.percentChange];
    //displays coloredStockProceeds on label
    NSString *stockProceeds = [stock calculateStockProceeds];
    [self formatStockProceeds:stockProceeds];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //create the tableViewCell with left and right justified appearance
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
    
    //get data to display for this cell
    int index = [indexPath indexAtPosition:1];
    NSString *alphabeticKey = [stockDetailsKeysArray objectAtIndex:index];
    NSString *value = [stock.stockDetailsDict objectForKey:alphabeticKey];
    [[cell textLabel] setText:alphabeticKey];
    [[cell detailTextLabel] setText:value];
    
    cell.textLabel.font = [UIFont fontWithName:@"Futura" size:16];
    cell.detailTextLabel.font = [UIFont fontWithName:@"Futura" size:16];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *allKeys = [stock.stockDetailsDict allKeys];
    return allKeys.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoTableView.frame.size.width, 0)];

    footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableFooter_lightBlue.png"]];
    
    return footerView;
}

-(void) configureTabBar {
    
    [portfolioTabBar setTintColor:[Globals kiwi_medBlueColor]];
    
    if ([[iOSVersionCheck sharedSingleton] isiOS7]) {
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"Futura" size:14.0f], UITextAttributeFont,
                                                           [Globals kiwi_darkBlueColor], UITextAttributeTextColor,
                                                           [Globals kiwi_whiteColor], UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                           nil] forState:UIControlStateNormal];
        
    } else {
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"Futura" size:14.0f], UITextAttributeFont,
                                                           [Globals kiwi_whiteColor], UITextAttributeTextColor,
                                                           [Globals kiwi_darkBlueColor], UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                           nil] forState:UIControlStateNormal];
    }
    
    
    UITabBarItem *sellStockItem = [[UITabBarItem alloc] initWithTitle:@"Sell Stock" image:[UIImage imageNamed:@"piggy_bank.png"] tag:1];
    [portfolioTabBar setItems:[[NSArray alloc] initWithObjects:sellStockItem, nil]];
    [portfolioTabBar setSelectedImageTintColor:[Globals kiwi_greenColor]];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 1) {
        [self sellStock];
    }
}
-(void) sizeTableViewRows
{
    //if they have iPhone 5, make rows bigger
    if ([[UIScreen mainScreen] bounds].size.height > 480) {
        infoTableView.rowHeight = 40;
        self.isiPhone5 = TRUE;
    } //if iPhone 4 make smaller
    else {
        infoTableView.rowHeight = 30;
        self.isiPhone5 = FALSE;
    }
}

- (void) configureTableView
{
    CGRect frame = infoTableView.frame;
//    frame.size.height = 270;
    frame.origin = CGPointMake(0, 37);
    if (self.isiPhone5) {
        frame.size.height = infoTableView.frame.size.height - 2;
    } else {
        frame.size.height = 270;
    }
    infoTableView.frame = frame;
    infoTableView.scrollEnabled = NO;
    [infoTableView setTableHeaderView: tableHeaderView];
    [stockNameLabel setText:stock.companyName];
}

- (void)sellStock {
    UIAlertView *tickerAlert = [[UIAlertView alloc] initWithTitle:@"Sell Stock?" message:@"Are you sure you want to sell your stock? This action can not be undone." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [tickerAlert show];
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //the cancelButtonTitle is 0 index, my accept (YES) is 1
    //the user wants to sell
    if (buttonIndex == 1)
    {
        portfolio.currentFunds = [NSNumber numberWithFloat:([portfolio.currentFunds floatValue] + (stock.currentPrice * stock.sharesBought))];
        [portfolio removeItem:stock];
        [portfolio calculatePercentChange];
        
        [[self navigationController] popViewControllerAnimated:YES];
        
    }
}

-(void)formatStockProceeds:(NSString *)numberString
{
    [self centerProceedsAndGLLabels];
    numberString = [numberString stringByReplacingOccurrencesOfString:@"," withString:@""];
    NSString *formattedString = [Globals formatCurrencyFloat:[numberString floatValue]];
    //if stock proceeds are negative, make red font color
    if ([formattedString hasPrefix:@"-$"]) {
        [stockValueNumberLabel setText:[NSString stringWithFormat:@"%@", formattedString]];
        [stockValueNumberLabel setTextColor:[Globals stockRedColor]];
    } else {
        [stockValueNumberLabel setText:[NSString stringWithFormat:@"%@", formattedString]];
        [stockValueNumberLabel setTextColor:[Globals stockGreenColor]];
    }
}

-(void)formatGLPercentage: (NSString *)percentString
{
    double percent = [percentString doubleValue];
        NSLog(@"double %f", percent);
    if (percent >= 0) {
        [stockGLNumberLabel setText: [NSString stringWithFormat:@"%@",percentString]];
        [stockGLNumberLabel setTextColor:[Globals stockGreenColor]];
    } else {
        [stockGLNumberLabel setText:percentString];
        [stockGLNumberLabel setTextColor:[Globals stockRedColor]];
    }
}

- (void)formatPositionPercentage: (NSString *)percentString
{
    
}

- (void) centerProceedsAndGLLabels
{
    float heightTilBottomRect = infoTableView.frame.size.height + portfolioHeader.frame.size.height;
    float heightOfBottomRect = ((self.view.frame.size.height - portfolioTabBar.frame.size.height) - heightTilBottomRect);
    float center = (heightOfBottomRect/2) - 2;
    
    
    CGRect GLNumberLabelFrame = stockGLNumberLabel.frame;
    GLNumberLabelFrame.origin = CGPointMake(240 - stockGLNumberLabel.frame.size.width/2, center+heightTilBottomRect);
    stockGLNumberLabel.frame = GLNumberLabelFrame;
    
    //center + heightTilBottomRect puts it at bottom of page and not top. -26 is so the label can go on top of number
    CGRect GLLabelFrame = stockGLLabel.frame;
    GLLabelFrame.origin = CGPointMake(240 - stockGLLabel.frame.size.width/2, center+heightTilBottomRect - 26);
    stockGLLabel.frame = GLLabelFrame;
    
    CGRect valueNumberLabelFrame = stockValueNumberLabel.frame;
    valueNumberLabelFrame.origin = CGPointMake(80 - stockValueNumberLabel.frame.size.width/2, center+heightTilBottomRect);
    stockValueNumberLabel.frame = valueNumberLabelFrame;
    
    CGRect valueLabelFrame = stockValueLabel.frame;
    valueLabelFrame.origin = CGPointMake(80 - stockValueLabel.frame.size.width/2, center+heightTilBottomRect - 26);
    stockValueLabel.frame = valueLabelFrame;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
