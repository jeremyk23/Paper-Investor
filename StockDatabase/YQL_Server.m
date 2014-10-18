//
//  YQL_Server.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/17/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "YQL_Server.h"
#import "YOSSocial.h"
#import "StockItem.h"
#import "PortfoliosStore.h"


@implementation YQL_Server
@synthesize session, queryResultsDictionary, requestDone;
NSString * const quote = @"\"";

+ (YQL_Server *)sharedServer
{
    //if single instance has been created, return it. otherwise create it.
    //static means it will never be destroyed
    static YQL_Server *sharedServer = nil;
    if (!sharedServer)
        sharedServer = [[super allocWithZone:nil] init];
    return sharedServer;
}
+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedServer];
}

-(id)init {
    //Yahoo Stuff
    YOSSession *session2 = [YOSSession sessionWithConsumerKey:@"dj0yJmk9bDU1VWRidFBhclFuJmQ9WVdrOWVrWlhWM1UzTkdFbWNHbzlNVEF4TWpFd09UazJNZy0tJnM9Y29uc3VtZXJzZWNyZXQmeD1iYg--" andConsumerSecret:@"2edab23986666d146b10004ba34168432d7b4e7e" andApplicationId:@"zFWWu74a"];
    self.session = session2;
    
    return self;
}
-(void)sendRequests: (NSString *)stockName{
    YQLQueryRequest *request = [YQLQueryRequest requestWithSession:self.session];
    
    NSString *queryTicker = [NSString stringWithFormat: @"%@%@%@", quote, stockName, quote];
    
    NSString *structuredStockQuery = [NSString stringWithFormat:@"select * from yahoo.finance.quotes where symbol in (%@)",queryTicker];
    
    [request query:structuredStockQuery withDelegate:self];
    
}

- (void)requestDidFinishLoading:(YOSResponseData *)data
{
    NSError *error;
    NSData *jsonData = [data.responseText dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    
    self.queryResultsDictionary = results;
    self.requestDone = TRUE;
    
}

-(void)refreshAllStockPrices: (NSMutableArray *)allStocks : (NSString *)jsonTag
{
    //send server requests
    NSString *allStockTickers = [self formatTickerName:allStocks];
    [self sendRequests:allStockTickers];
    self.requestDone = FALSE;
    
    //Loop to wait for server to finish loading
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
    while (!self.requestDone && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    //store json stock info dictionary in qouteEntries array
    NSArray *quoteEntries = [self.queryResultsDictionary valueForKeyPath:@"query.results.quote"];
    
    //int i will be used to loop through all stocks in the current portfolio
    int i = 0;
    
    //IF there is only one stock YQL doesn't create an array which throws an error (becuase the dictionary doesn't create an array?)
    if (allStocks.count == 1) {
        if ([[quoteEntries valueForKeyPath :@"symbol"] isEqualToString:[[allStocks objectAtIndex:i] stockName]]) {
            
            //set the new current price of the users stocks
            NSString *queriedValue = [quoteEntries valueForKeyPath : [NSString stringWithFormat:@"%@", jsonTag]];
            float newCurrentPrice = [queriedValue floatValue];
            StockItem *stock = [allStocks objectAtIndex:i];
            [self fillStockDetailsArray:quoteEntries :stock];
            stock.currentPriceFormatted = queriedValue;
            stock.currentPrice = newCurrentPrice;
        }
    }
    //if there is more than one stock in the allStocks Array, create an array for each stock info in the JSON array
    else {
        for (NSArray *arrayOfStockInfo in quoteEntries){
            //check to see if current array in dict is the same as the current stock in the StockItemStore
            if ([[arrayOfStockInfo valueForKeyPath :@"symbol"] isEqualToString:[[allStocks objectAtIndex:i] stockName]]) {
                
                //set the new current price of the users stocks
                NSString *queriedValue = [arrayOfStockInfo valueForKeyPath : [NSString stringWithFormat:@"%@", jsonTag]];
                float newCurrentPrice = [queriedValue floatValue];
                StockItem *stock = [allStocks objectAtIndex:i];
                [self fillStockDetailsArray:arrayOfStockInfo :stock];
                stock.currentPriceFormatted = queriedValue;
                stock.currentPrice = newCurrentPrice;
                
            }
            else {
                NSLog(@"Query dict is not in same order. Current Array symbol: %@, doesn't equal allStocks array symbol: %@", [arrayOfStockInfo valueForKeyPath :@"symbol"], [[allStocks objectAtIndex:i] stockName]);
            }
            i+=1;
        }
    }
}

-(NSString *)returnStockInfo:(StockItem *)stock : (NSString *)jsonTag
{
    //send a request for the server.
    [self sendRequests:stock.stockName];
    self.requestDone = FALSE;
    
    //Loop to wait for server to finish loading
    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
    while (!self.requestDone && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    //make a formatted string with the specified JSON tag to return the info on the stock I want.
    NSString *keyPath = [NSString stringWithFormat:@"query.results.quote.%@",jsonTag];
    NSString *returnInfo = [self.queryResultsDictionary valueForKeyPath:keyPath];
    
    //if stock doesn't have detailed info...might as well get it now.
    if (!stock.stockDetailsDict) {
        NSArray *quoteEntries = [self.queryResultsDictionary valueForKeyPath:@"query.results.quote"];
        [self fillStockDetailsArray:quoteEntries :stock];
    }
    
    return returnInfo;
    
    //how to get an array
    //    NSArray *quoteEntries = [self.queryResultsDictionary valueForKeyPath:@"query.results.quote"];
}

-(NSString *)formatTickerName:(NSArray *)allStocks
{
    //create slash quote for YQL formatting
    NSString *quote = @"\"";
    NSMutableString *fullStockTicker = [[NSMutableString alloc] init];
    NSString *str = [[NSString alloc] init];
    
    //if only one stock in array, just return its name
    if ([allStocks count] == 1) {
        return [[allStocks objectAtIndex:0] stockName];
    }
    
    for (int i = 0; i < [allStocks count]; i++) {
        //if its first stock, dont put a qoutation mark in front of it
        if (i == 0) {
            str = [NSString stringWithFormat: @"%@%@,", [[allStocks objectAtIndex:0] stockName], quote];
        }
        //if its the last stock, don't put a comma and quotation next to it
        else if (i == [allStocks count] -1 ){
            str = [NSString stringWithFormat: @"%@%@", quote, [[allStocks objectAtIndex:i] stockName]];
        } else {
            str = [NSString stringWithFormat: @"%@%@%@,", quote, [[allStocks objectAtIndex:i] stockName] , quote];
        }
        
        [fullStockTicker appendString:str];
    }
    return fullStockTicker;
}

-(void)fillStockDetailsArray:(NSArray *)jsonArray :(StockItem *)s
{
    if (!s.stockDetailsDict) {
        s.stockDetailsDict = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    NSMutableString *queriedValue = [jsonArray valueForKeyPath : @"DaysHigh"];
    [s.stockDetailsDict setObject:queriedValue forKey:@"Days High"];
    
    queriedValue = [jsonArray valueForKeyPath : @"DaysLow"];
    [s.stockDetailsDict setObject:queriedValue forKey:@"Days Low"];
    
    queriedValue = [jsonArray valueForKeyPath : @"YearHigh"];
    [s.stockDetailsDict setObject:queriedValue forKey:@"Year High"];
    
    queriedValue = [jsonArray valueForKeyPath : @"YearLow"];
    [s.stockDetailsDict setObject:queriedValue forKey:@"Year Low"];
    
    queriedValue = [jsonArray valueForKeyPath : @"EarningsShare"];
    [s.stockDetailsDict setObject:queriedValue forKey:@"EPS"];
    
    queriedValue = [jsonArray valueForKeyPath : @"MarketCapitalization"];
    [s.stockDetailsDict setObject:queriedValue forKey:@"Market Cap"];
    
    queriedValue = [jsonArray valueForKeyPath : @"PercentChange"];
    [s.stockDetailsDict setObject:queriedValue forKey:@"Days Change"];
    
}
@end
