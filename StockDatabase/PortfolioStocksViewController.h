//
//  PortfolioStocksViewController.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 8/11/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DetailViewController.h"
#import "StockItemCell.h"
#import "EntryScreenViewController.h"

@class UserPortfolio;

@interface PortfolioStocksViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITabBarDelegate, UIAlertViewDelegate>
{
    IBOutlet UITableView *infoTableView;
    
    __weak IBOutlet UIView *portfolioHeaderView;
    IBOutlet __weak UILabel *fundsLabel;
    IBOutlet __weak UILabel *portfolioLabel;
    IBOutlet __weak UILabel *percentGLLabel;
    __weak IBOutlet UITabBar *portfolioTabBar;
    
    //this header view doesn't deal with its its viewControllers "view" becuase ItemsVC already knows how to create its view.
    UIActivityIndicatorView *acitivityIndicator;

}

-(void)passParentView:(EntryScreenViewController *)theParent;
-(void)setPortfolio:(UserPortfolio *)p;
-(BOOL)determineColor:(UserPortfolio *)port;

-(void)configureTableView;

//footer methods
-(void)configureTabBar;
-(void)deletePortfolio;
-(void)createStock;

@property (nonatomic, strong) UserPortfolio *portfolio;
@property (nonatomic, strong) EntryScreenViewController *theParentView;

@end
