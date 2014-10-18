//
//  ItemsViewController.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/7/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DetailViewController.h"
#import "StockItemCell.h"
@class UserPortfolio;

//ItemsViewController is instance of UITableViewController 
@interface ItemsViewController : UITableViewController <UITabBarDelegate>
{
     UIColor *const GREEN_COLOR;
     UIColor *const RED_COLOR;
    IBOutlet __weak UILabel *fundsLabel;
    IBOutlet __weak UILabel *portfolioLabel;
    IBOutlet __weak UILabel *percentGLLabel;
    __weak IBOutlet UIButton *deletePortfolioButton;
    __weak IBOutlet UIButton *createStockButton;
    __weak IBOutlet UITabBar *portfolioTabBar;
    //this header view doesn't deal with its its viewControllers "view" becuase ItemsVC already knows how to create its view.
    IBOutlet UIView *portfolioHeaderView;
    IBOutlet UIView *portfolioFooterView;
}

-(UIView *)portfolioHeaderView;
-(UIView *)portfolioFooterView;

-(void)setPortfolio:(UserPortfolio *)p;
-(IBAction)addNewItem:(id)sender;
-(BOOL)determineColor:(StockItem *)stock;

//footer methods
-(IBAction)deletePortfolio:(id)sender;
-(IBAction)createStock:(id)sender;

@property (nonatomic, strong) UserPortfolio *portfolio;

@end
