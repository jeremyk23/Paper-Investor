//
//  YQL_Server.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/17/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

//
//  YQL_Server.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/17/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YOSSocial.h"
@class StockItem;

@interface YQL_Server : NSObject
extern NSString * const quote;

+ (YQL_Server *)sharedServer;
-(void)sendRequests: (NSString *)stockName;
-(void)refreshAllStockPrices: (NSMutableArray *)allStocks : (NSString *)jsonTag;
-(NSString *)returnStockInfo:(StockItem *)stock : (NSString *)jsonTag;
-(NSString *)formatTickerName:(NSArray *)allStocks;
-(void)fillStockDetailsArray:(NSArray *)jsonArray : (StockItem *)s;

@property (nonatomic, strong) YOSSession *session;
@property (nonatomic, copy) NSDictionary *queryResultsDictionary;
@property (nonatomic) BOOL requestDone;


@end

