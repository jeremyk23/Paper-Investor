//
//  PortfolioStocksViewController.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 8/11/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//
#include <math.h>

#import "PortfolioStocksViewController.h"
#import "StockItem.h"
#import "YQL_Server.h"
#import "UserPortfolio.h"
#import "PortfoliosStore.h"
#import "StocksViewController.h"
#import "Globals.h"
#import "iOSVersionCheck.h"

@interface PortfolioStocksViewController ()

@end

@implementation PortfolioStocksViewController
@synthesize portfolio, theParentView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)passParentView:(EntryScreenViewController *)theParent
{
    theParentView = theParent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Globals formatForiOS7:self];
    
    //Initialize Navigation Bar
    UINavigationItem  *n = [self navigationItem];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont
                                                                           fontWithName:@"futura" size:14], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];
    [[UINavigationBar appearance] setTitleTextAttributes:attributes];
    [n setTitle:portfolio.title];
    
    
    //set background image
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenBG_2.png"]];
    [self.view addSubview:backgroundView];
    backgroundView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view sendSubviewToBack:backgroundView];
    [self.view insertSubview:portfolioHeaderView aboveSubview:backgroundView];
    
    //load cell nib file
    UINib *nib = [UINib nibWithNibName:@"StockItemCell" bundle:nil];
    [infoTableView registerNib:nib forCellReuseIdentifier:@"StockItemCell"];
    
    //if they're any stocks in the portfolio
    if (portfolio.allStocks.count) {
        //refresh all stock prices
        [[YQL_Server sharedServer] refreshAllStockPrices:(portfolio.allStocks) : @"LastTradePriceOnly" ];
        //refresh gain/loss percentage
        for (StockItem *s in portfolio.allStocks) {
            s.percentChange = [s calculatePercentChange];
        }
    }
    [theParentView.activityIndicator stopAnimating];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [infoTableView reloadData];
    
    NSString *str = [NSString stringWithFormat:@"Total Funds: %@",[Globals formatCurrencyFloat:[portfolio.currentFunds floatValue]]];
    [fundsLabel setText:str];
    
    //calculate portfolio change
    [portfolio calculatePercentChange];
    if (isnan([portfolio.percentChange floatValue])) {
        [percentGLLabel setText:@"0%"];
    } else {
    [percentGLLabel setText: [NSString stringWithFormat:@"%@%%", [Globals formatFloat:[portfolio.percentChange floatValue]]]];
    }
    if (![self determineColor:portfolio]) {
        [percentGLLabel setTextColor:[Globals stockRedColor]];
    }
    [self configureTableView];
    [self configureTabBar];
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StocksViewController *stocksViewController = [[StocksViewController alloc] init];
    
    NSArray *items = portfolio.allStocks;
    StockItem *selectedItem = [items objectAtIndex:[indexPath row]];
    
    [stocksViewController setStockAndPortfolio:selectedItem :portfolio];
    
    //push it onto the top of the navigation controller's stack
    [[self navigationController] pushViewController:stocksViewController
                                           animated:YES];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //set the text on the cell with the description of the item that is at nth index of items, where n = rows in this cell
    StockItem *p = [portfolio.allStocks objectAtIndex:[indexPath row]];
    //get the new or recycled cell
    StockItemCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StockItemCell"];
    
    //configure numbers for float representation
    p.pricePaidFormatted = [Globals formatFloat:p.pricePaid];
    p.currentPriceFormatted = [Globals formatFloat:p.currentPrice];
    
    //configure the cell with the StockItem
    [[cell tickerLabel] setText:[p stockName]];
    [[cell priceBoughtLabel] setText: [NSString stringWithFormat:@"Price Paid: %@", p.pricePaidFormatted]];
    [[cell currentPriceLabel]setText: [NSString stringWithFormat:@"Current Price: %@", p.currentPriceFormatted]];
    
    
    //if percent change was positive, determineColor will return true and set label to green
    if (p.positive) {
        cell.percentLabel.textColor = [Globals stockGreenColor];
    } else {
        cell.percentLabel.textColor = [Globals stockRedColor];
    }
    [[cell percentLabel] setText:p.percentChange];
    

    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [portfolio.allStocks count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 10;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, infoTableView.frame.size.width, 0)];
    
    footerView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tableFooter_lightBlue.png"]];
    
    return footerView;
}




- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (item.tag == 1) {
        [self deletePortfolio];
    }
    else if (item.tag == 2) {
        [self createStock];
    }
}

-(void)deletePortfolio {
    UIAlertView *tickerAlert = [[UIAlertView alloc] initWithTitle:@"Delete Portfolio?" message:@"Are you sure you want to delete your portfolio? This action can not be undone." delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [tickerAlert show];
    
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //the cancelButtonTitle is 0 index, my accept (YES) is 1
    //the user wants to sell
    if (buttonIndex == 1)
    {
        [[PortfoliosStore sharedStore] removeItem:portfolio];
        
        [[self navigationController] popViewControllerAnimated:YES];
        
    }
}

-(void)createStock
{
    StockItem *newItem = [portfolio createStock];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    [detailViewController setStockAndPortfolio:newItem : portfolio];
    
    [[self navigationController] pushViewController:detailViewController animated:YES];
}


-(void)setPortfolio:(UserPortfolio *)p
{
    portfolio = p;
}

-(BOOL)determineColor:(UserPortfolio *)port
{
    //Boolean instance variable (positive) of StockItem indicates green if True, red if false
    if ([port.percentChange floatValue] < 0) {
        return FALSE;
    } else {
        return TRUE;
    }
}

-(void)configureTabBar {
    //if it's ios7, make tab bar text Dark blue. Else make white.
    
    if ([[iOSVersionCheck sharedSingleton] isiOS7]) {
        [portfolioTabBar setTintColor:[Globals kiwi_medBlueColor]];

        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"Futura" size:14.0f], UITextAttributeFont,
                                                           [Globals kiwi_darkBlueColor], UITextAttributeTextColor,
                                                           [Globals kiwi_whiteColor], UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                           nil] forState:UIControlStateNormal];
        

    } else {
        [portfolioTabBar setTintColor:[Globals kiwi_medBlueColor]];
        
        [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIFont fontWithName:@"Futura" size:14.0f], UITextAttributeFont,
                                                           [Globals kiwi_whiteColor], UITextAttributeTextColor,
                                                           [Globals kiwi_darkBlueColor], UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                           nil] forState:UIControlStateNormal];
    }
    UITabBarItem *deletePortfolioItem = [[UITabBarItem alloc] initWithTitle:@"Delete Portfolio" image:[UIImage imageNamed:@"waste_basket.png"] tag:1];
    
    UITabBarItem *purchaseStockItem = [[UITabBarItem alloc] initWithTitle:@"Purchase Stock" image:[UIImage imageNamed:@"plus.png"] tag:2];
    
    [portfolioTabBar setItems:[[NSArray alloc] initWithObjects:deletePortfolioItem, purchaseStockItem, nil]];
    [portfolioTabBar setSelectedImageTintColor:[Globals kiwi_greenColor]];
}

-(void)configureTableView
{
    int numberOfRows = portfolio.allStocks.count;
    float tableHeight = infoTableView.rowHeight * numberOfRows;
    if (tableHeight > (self.view.frame.size.height - portfolioTabBar.frame.size.height - 44)) {
        infoTableView.scrollEnabled = YES;
        CGRect frame = infoTableView.frame;
        frame.size.height = (self.view.frame.size.height - portfolioTabBar.frame.size.height - 44);
        frame.origin = CGPointMake(0, 44);
        infoTableView.frame = frame;
    } else {
        infoTableView.scrollEnabled = NO;
        CGRect frame = infoTableView.frame;
        frame.size.height = tableHeight +  10;
        frame.origin = CGPointMake(0, 44);
        infoTableView.frame = frame;
        [infoTableView setContentSize:CGSizeMake(infoTableView.contentSize.width, tableHeight)];
    }

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
