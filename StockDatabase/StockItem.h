//
//  StockItem.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/25/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UserPortfolio.h"
#import "YQL_Server.h"


@interface StockItem : NSManagedObject

+(id)createDefaultStock;

- (id)initWithItemName:(NSString *)name
          currentPrice:(float)value
             pricePaid:(float)value2;
-(NSString *)formatFloat:(float)number;

-(NSString *)calculatePercentChange;

-(NSString *)calculateStockProceeds;

- (void)buyStockAtPriceAndDate:(NSString *)name stockItem:(StockItem *)stock forPortfolio:(UserPortfolio *)portfolio sharesBought:(int)shares pricePaid:(float)price dateCreated:(NSString *)dateStr;

-(float)purchasedMarketValue;
-(float)currentMarketValue;

@property (nonatomic, retain) NSString * stockName;
@property (nonatomic, retain) NSString * companyName;
@property (nonatomic) float pricePaid;
@property (nonatomic, retain) NSString * pricePaidFormatted;
@property (nonatomic) float currentPrice;
@property (nonatomic, retain) NSString * currentPriceFormatted;
@property (nonatomic) NSTimeInterval dateCreated;
@property (nonatomic, retain) NSString * percentChange;
@property (nonatomic) BOOL positive;
@property (nonatomic) double orderingValue;
@property (nonatomic, retain) NSString *portfolioString;
@property (nonatomic, retain) NSManagedObject *portfolioType;
@property (nonatomic) int16_t sharesBought;


@property (nonatomic, strong) NSMutableDictionary *stockDetailsDict;
//Index of specific stockDetails
//0:DaysHigh  1:DaysLow   2:YearHigh  3:YearLow   4:EarningsShare
//5:MarketCapitalization  6:Name      7:PercentChange

@end
