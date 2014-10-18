//
//  UserPortfolio.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/26/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

//Stuffs to worry about ---- date of portfolio is not set with awakeFromInsert with an NSTimeInterval

#import "UserPortfolio.h"
#import "StockItem.h"
#import "PortfoliosStore.h"
#import "Globals.h"


@implementation UserPortfolio
@synthesize allStocks, percentChange;


-(id)init
{
    self = [super init];
    if (self) {
        //if array hadn't already been saved previously, create a new empty one
        if (!allStocks) {
            allStocks = [[NSMutableArray alloc] init];
        }
    }
    return self;
}

//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX - THIS FUNCTION SHOULD BE HERE XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
//-(NSArray *)allStocks
//{
//    return allStocks;
//}

-(StockItem *)createStock
{    
    double order;
    if ([allStocks count] == 0)
    {
        order = 1.0;
    } else {
        order = [[allStocks lastObject] orderingValue] + 1.0;
    }
//    NSLog(@"Adding after %d items, order = %.2f", allStocks.count, order);
    
    StockItem *p = [NSEntityDescription insertNewObjectForEntityForName:@"StockItem" inManagedObjectContext:[[PortfoliosStore sharedStore] context]];
    
    [p setOrderingValue:order];
    if (!self.allStocks)
    {
        self.allStocks = [[NSMutableArray alloc] init];
        NSLog(@"allStocks array wasn't initialized until first stock was created");
    }
    
    [self.allStocks addObject:p];
    
    return p;
}

-(void)removeItem:(StockItem *)p
{
    [PortfoliosStore.sharedStore.context deleteObject:p];
    [allStocks removeObjectIdenticalTo:p];
}
-(void)moveItemAtIndex:(int)from toIndex:(int)to
{
    if (from == to){
        return;
    }
    //get pointer to object so we can re-insert it
    StockItem *p = [allStocks objectAtIndex:from];
    //remove p from array
    [allStocks removeObjectAtIndex:from];
    //insert p into array at new location
    [allStocks insertObject:p atIndex:to];
    
    //computing a new orderValue for the object that was moved
    double lowerBound = 0.0;
    
    //is there an object before it in the array?
    if (to > 0) {
        lowerBound = [[allStocks objectAtIndex:to -1] orderingValue];
    } else {
        lowerBound = [[allStocks objectAtIndex:1] orderingValue] - 2.0;
    }
    double upperBound = 0.0;
    
    //is there an object after it in the array
    if (to < allStocks.count -1) {
        upperBound = [[allStocks objectAtIndex:to + 1] orderingValue];
    } else {
        upperBound = [[allStocks objectAtIndex:to - 1] orderingValue] + 2.0;
    }
    
    double newOrderValue = (lowerBound + upperBound) / 2.0;
    
//    NSLog(@"moving to order %f", newOrderValue);
    [p setOrderingValue:newOrderValue];
    
}

- (NSString *)description
{
    NSString *descriptionString =
    [[NSString alloc] initWithFormat:@"Portfolio Title: %@ . currentFunds: %@. Description: %@",
     self.title,
     self.currentFunds,
     self.descriptionOfPortfolio];
    return descriptionString;
}

-(void)calculatePercentChange
{
    float totalCurrentValue = 0.0;
    for (StockItem *s in self.allStocks) {
        totalCurrentValue += s.currentPrice * s.sharesBought;
    }
    
    float totalInitialValue = 0.0;
    for (StockItem *s in self.allStocks) {
        totalInitialValue += s.pricePaid * s.sharesBought;
    }
    float change = ((totalCurrentValue - totalInitialValue) / totalInitialValue);
    change *=100;
    self.percentChange = [NSNumber numberWithFloat:change];
}

-(NSString *)calculatePercentageOfPortfolio : (StockItem *)stock {
    float totalCost = 0.0;
    for (StockItem *s in self.allStocks) {
        totalCost += s.currentPrice * s.sharesBought;
    }
    float cost = stock.pricePaid * stock.sharesBought;
    float percent = (cost / totalCost) * 100;
    NSString *percentString = [Globals formatFloat:percent];
    return percentString;
}

-(void)purchaseStock:(StockItem *)stock {
    self.currentFunds = [NSNumber numberWithFloat:[self.currentFunds floatValue] - (stock.pricePaid * stock.sharesBought)];
}



@dynamic title;
@dynamic descriptionOfPortfolio;
@dynamic initialFunds;
@dynamic currentFunds;
@dynamic dateCreated;

@end
