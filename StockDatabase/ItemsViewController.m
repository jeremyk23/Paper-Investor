//
//  ItemsViewController.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/7/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "ItemsViewController.h"
#import "StockItem.h"
#import "UIColor+Custom_Color.h"
#import "YQL_Server.h"
#import "UserPortfolio.h"
#import "PortfoliosStore.h"
#import "StocksViewController.h"
#import "Globals.h"


@implementation ItemsViewController
@synthesize portfolio;

-(void)setPortfolio:(UserPortfolio *)p
{
    portfolio = p;
}

- (id) init{
    //call the superclass's designated initializer
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self){
        //create a new button on the navigation bar that will send addNewItem to ItemViewController
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewItem:)];
        //set this bar button item as the top right button on the nav bar
        [[self navigationItem] setRightBarButtonItem:bbi];
        
//        if no left button is specified, back button is the default
//        [[self navigationItem] setLeftBarButtonItem:[self editButtonItem]];
        
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[self tableView] reloadData];
//    [portfolioLabel setText:portfolio.title];
    NSString *str = [NSString stringWithFormat:@"Total Funds: $%@",[Globals formatFloat:[portfolio.currentFunds floatValue]]];
    [fundsLabel setText:str];
    
    //calculate portfolio change
    [portfolio calculatePercentChange];
    [percentGLLabel setText: [NSString stringWithFormat:@"%@%%", [Globals formatFloat:[portfolio.percentChange floatValue]]]];
}

//register the StockCell XIB with the UITableView for a given reuse identifier when the table first loads.
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Initialize Navigation Bar
    UINavigationItem  *n = [self navigationItem];
    [n setTitle:portfolio.title];
    
    UITabBar *tabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0, self.tableView.backgroundView.frame.size.height-88, 320, 44)];
    [self.tableView addSubview:tabBar];
    [tabBar setTintColor:[Globals kiwi_medBlueColor]];
    [tabBar setSelectedImageTintColor:[Globals kiwi_medBlueColor]];
    
    UITabBarItem *deletePortfolioItem = [[UITabBarItem alloc] initWithTitle:@"Delete Portfolio" image:[UIImage imageNamed:@"waste_basket.png"] tag:1];
    
    UITabBarItem *purchaseStockItem = [[UITabBarItem alloc] initWithTitle:@"Purchase Stock" image:[UIImage imageNamed:@"plus.png"] tag:2];
    
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIFont fontWithName:@"Futura" size:8.0f], UITextAttributeFont,
                                                       [Globals kiwi_whiteColor], UITextAttributeTextColor,
                                                       [Globals kiwi_darkBlueColor], UITextAttributeTextShadowColor,
                                                       [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)], UITextAttributeTextShadowOffset,
                                                       nil] forState:UIControlStateNormal];
    
//    [[UITabBarItem appearance] setTitleColor:[Globals kiwi_whiteColor] forState:UIControlStateNormal];
    
    //         [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTintColor:myNavBarColor];
    
    [tabBar setItems:[[NSArray alloc] initWithObjects:deletePortfolioItem, purchaseStockItem, nil]];
    [tabBar setSelectedImageTintColor:[Globals kiwi_greenColor]];
    
    //set background image
    self.tableView.backgroundView = nil;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenBG_2.png"]];
    self.tableView.backgroundView.center = CGPointMake(self.tableView.frame.size.width/2, self.tableView.frame.size.height/2);
    
    [self.tableView setSeparatorColor:[Globals kiwi_lightBlueColor]];
    //load the NIB file
    UINib *nib = [UINib nibWithNibName:@"StockItemCell" bundle:nil];
    
    //Register this NIB wihich contains the cell
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"StockItemCell"];
    
    [[NSBundle mainBundle] loadNibNamed:@"FooterItemView" owner:self options:nil];
    
    //if they're any stocks in the portfolio
    if (portfolio.allStocks.count) {
        
        //refresh all stock prices
        [[YQL_Server sharedServer] refreshAllStockPrices:(portfolio.allStocks) : @"LastTradePriceOnly" ];
        //refresh gain/loss percentage
        for (StockItem *s in portfolio.allStocks) {
            s.percentChange = [s calculatePercentChange];
        }
    }
}


- (id)initWithStyle:(UITableViewStyle)style
{
    return [self init];
}


//Initialize Header
-(UIView *)portfolioHeaderView;
{
    // If we haven't loaded the headerView yet...
    if (!portfolioHeaderView) {
        // Load PortfolioView.xib
        [[NSBundle mainBundle] loadNibNamed:@"PortfolioHeader" owner:self options:nil];
        //set header values
        
    }
    return portfolioHeaderView;
}

//UITableViewDelegate method for SETTING HEADER TO PortfolioHeader
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.portfolioHeaderView;
}

//Sets the the height for the header in ItemsViewController equal to height of my XIB file
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [self.portfolioHeaderView bounds].size.height;
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
    p.pricePaidFormatted = [p formatFloat:p.pricePaid];
    p.currentPriceFormatted = [p formatFloat:p.currentPrice];
    
    //configure the cell with the StockItem
    [[cell tickerLabel] setText:[p stockName]];
    [[cell priceBoughtLabel] setText: [NSString stringWithFormat:@"Price Paid: %@", p.pricePaidFormatted]];
    [[cell currentPriceLabel]setText: [NSString stringWithFormat:@"Current Price: %@", p.currentPriceFormatted]];
    
    
    //if percent change was positive, determineColor will return true and set label to green
    if ([self determineColor:p]) {
        cell.percentLabel.textColor = [UIColor stockGreenColor];
    } else {
        cell.percentLabel.textColor = [UIColor stockRedColor];
    }
    [[cell percentLabel] setText:p.percentChange];
    
    return cell;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [portfolio.allStocks count];
}


-(IBAction)addNewItem:(id)sender
{
    //table is only the view portion. The StockStore is where the data is kept, (the ItemsViewController is the dataSource), so I need to update Store for new rows.
    StockItem *newItem = [portfolio createStock];
    
    DetailViewController *detailViewController = [[DetailViewController alloc] init];
    [detailViewController setStockAndPortfolio:newItem : portfolio];
    
    [[self navigationController] pushViewController:detailViewController animated:YES];
    
}

//delete method
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if the table view is asking to commit a delete command
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        StockItemCell *cell;
        cell.percentLabel.hidden = YES;
        
        NSArray *stocks = portfolio.allStocks;
        StockItem *p = [stocks objectAtIndex:[indexPath row]];
        [portfolio removeItem:p];
        
        //we also remove that row from the table view with an animation
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [portfolio moveItemAtIndex:[sourceIndexPath row] toIndex:[destinationIndexPath row]];
}



-(BOOL)determineColor:(StockItem *)stock
{
    //Boolean instance variable (positive) of StockItem indicates green if True, red if false
    if (stock.positive == TRUE) {
        return TRUE;
    }
    if (stock.positive == FALSE) {
        return FALSE;
    } else {
        return TRUE;
    }
}

@end
