//
//  StocksViewController.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/30/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemsViewController.h"

@class StockItem, UserPortfolio;

@interface StocksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITabBarDelegate>
{
    IBOutlet UITableView *infoTableView;
    IBOutlet UIView *tableHeaderView;
    
    __weak IBOutlet UIView *stockHeaderView;
    __weak IBOutlet UITabBar *portfolioTabBar;
    __weak IBOutlet UILabel *stockNameLabel;
    __weak IBOutlet UITabBar *sellTabBar;
    __weak IBOutlet UILabel *totalFundsLabel;
    __weak IBOutlet UILabel *prcntOfPortfolioLabel;
    __weak IBOutlet UILabel *stockValueNumberLabel;
    __weak IBOutlet UILabel *stockGLLabel;
    __weak IBOutlet UILabel *stockValueLabel;
    __weak IBOutlet UILabel *purchaseDateLabel;
    __weak IBOutlet UILabel *stockGLNumberLabel;
    __weak IBOutlet UIView *portfolioHeader;
}

- (void)setStockAndPortfolio:(StockItem *)s : (UserPortfolio *)port;
- (void)formatStockProceeds:(NSString *)numberString;
- (void)formatGLPercentage: (NSString *)percentString;
- (void)formatPositionPercentage: (NSString *)percentString;
- (void)configureTableView;
- (void)configureTabBar;
- (void)sizeTableViewRows;


@property (nonatomic, strong) StockItem *stock;
@property (nonatomic, strong) UserPortfolio *portfolio;
@property (nonatomic, strong) NSArray *stockDetailsKeysArray;
@property  BOOL isiPhone5;

@end

//UiTV needs a view controller to handles its appearance: (contentView)
//needs a data source for number of rows to display, data to be shown: (self)
//needs a delegate to inform other objects of events involving UiTV: (self)
//UITableViewController's do all three of the above but I will just use a UITableView

//sets the table's frame size. Can only happen hear or else viewDidLoad will resize it.
