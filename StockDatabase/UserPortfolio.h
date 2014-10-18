//
//  UserPortfolio.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/26/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
@class StockItem;

@interface UserPortfolio : NSManagedObject

//-(NSArray *)allStocks;
-(StockItem *)createStock;
-(void)removeItem:(StockItem *)p;
-(void)moveItemAtIndex:(int)from toIndex:(int)to;
-(void)purchaseStock:(StockItem *)stock;
-(void)calculatePercentChange;
-(NSString *)calculatePercentageOfPortfolio : (StockItem *)stock;

@property (nonatomic, strong) NSMutableArray *allStocks;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * descriptionOfPortfolio;
@property (nonatomic, retain) NSNumber * initialFunds;
@property (nonatomic, retain) NSNumber * currentFunds;
@property (nonatomic, retain) NSDate * dateCreated;
@property (nonatomic, retain) NSNumber *percentChange;

@end
