//
//  StockItem.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/25/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "StockItem.h"
#import "Globals.h"



@implementation StockItem

@dynamic stockName;
@dynamic companyName;
@dynamic pricePaid;
@dynamic pricePaidFormatted;
@dynamic currentPrice;
@dynamic currentPriceFormatted;
@dynamic dateCreated;
@dynamic percentChange;
@dynamic positive;
@dynamic orderingValue;
@dynamic portfolioType;
@dynamic portfolioString;
@dynamic sharesBought;

@synthesize stockDetailsDict;


-(void)awakeFromFetch
{
    [super awakeFromFetch];
}

//When a user creates an object, it is added to the database, which sends the message awakeFromInsert. This is where I set dateCreated.
-(void) awakeFromInsert
{
    [super awakeFromInsert];
    NSTimeInterval t = [[NSDate date] timeIntervalSinceReferenceDate];
    [self setDateCreated:t];
}

+(id)createDefaultStock
{
    StockItem *newStock = [[self alloc] initWithItemName:@"Enter Stock Info" currentPrice:0.0 pricePaid:0.0];
    return newStock;
}

- (id)initWithItemName:(NSString *)name
          currentPrice:(float)value
             pricePaid:(float)value2;
{
    // Call the superclass's designated initializer
    self = [super init];
    self.positive = TRUE;
    
    // Did the superclass's designated initializer succeed?
    if(self) {
        // Give the instance variables initial values
        [self setStockName:name];
        [self setPricePaid:value2];
        [self setCurrentPrice:value];
        NSTimeInterval t = [[NSDate date] timeIntervalSinceReferenceDate];
        [self setDateCreated:t];
        if (!self.stockDetailsDict) {
            self.stockDetailsDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        }
        
    }
    
    // Return the address of the newly initialized object
    return self;
}

- (id)init
{
    return [self initWithItemName:@"Stock"
                     currentPrice:1 pricePaid:0];
}

- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"%@ Current Price: %f. Price Paid: %f. Percent Change: %@",
     self.stockName,
     self.currentPrice,
     self.pricePaid,
     self.percentChange];
    return descriptionString;
}
- (void)dealloc
{
    NSLog(@"Destroyed: %@ ", self);
}

//don't need this method should be replaced later by calling global function instead
//It's still used in PortfolioStocksViewController to set PricePaid
-(NSString *)formatFloat:(float)number
{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    //    [formatter setRoundingMode:NSNumberFormatterRoundUp];
    NSString *numberString = [formatter stringFromNumber:[NSNumber numberWithFloat:number]];
    return numberString;
}

-(float)purchasedMarketValue {
    float marketValue = self.sharesBought * self.pricePaid;
    return marketValue;
}

-(float)currentMarketValue {
    float marketValue = self.sharesBought * self.currentPrice;
    return marketValue;
}

-(NSString *)calculatePercentChange
{
    float percent = ((self.currentPrice - self.pricePaid)/self.pricePaid) * 100;
    
    //is it positive or negative growth?
    if (percent > 0) {
        self.positive = TRUE;
        NSString *numberString = [Globals formatFloat:percent];
        NSString *numberWithPercent = [NSString stringWithFormat:@"+%@%%",numberString];
        return numberWithPercent;
    } else {
        self.positive = FALSE;
        NSString *numberString = [Globals formatFloat:percent];
        NSString *numberWithPercent = [NSString stringWithFormat:@"%@%%",numberString];
        return numberWithPercent;
    }
}


-(NSString *)calculateStockProceeds
{
    float initialValue = self.pricePaid * self.sharesBought;
    float currentValue = self.currentPrice * self.sharesBought;
    float proceeds = currentValue - initialValue;
    NSString *numberString = [Globals formatFloat:proceeds];
    
    return numberString;
}


//--------------------------TEST SUITE---------------------------\\

- (void)buyStockAtPriceAndDate:(NSString *)name stockItem:(StockItem *)stock forPortfolio:(UserPortfolio *)portfolio sharesBought:(int)shares pricePaid:(float)price dateCreated:(NSString *)dateStr {
    /*
     stock.stockName = name;
     stock.sharesBought = shares;
     
     stock.pricePaid = price;
     stock.pricePaidFormatted = [Globals formatFloat:stock.pricePaid];
     
     stock.currentPriceFormatted = [[YQL_Server sharedServer] returnStockInfo:stock :@"LastTradePriceOnly"];
     stock.currentPrice = [Globals formatStringToFloat:stock.currentPriceFormatted];
     stock.companyName = [[YQL_Server sharedServer] returnStockInfo:stock :@"Name"];
     
     [stock setPercentChange:[stock calculatePercentChange]];
     [stock calculateStockProceeds];
     [stock calculatePercentChange];
     
     NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
     [dateFormat setDateFormat:@"MM/dd/yyyy"];
     NSLog(@"dateStr: %@",dateStr);
     NSDate *date = [dateFormat dateFromString:dateStr];
     NSLog(@"NSDate: %@",date);
     NSTimeInterval t = [date timeIntervalSinceReferenceDate];
     [stock setDateCreated:t];
     
     [portfolio purchaseStock:stock];
     */
}
@end
