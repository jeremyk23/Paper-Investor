//
//  PortfoliosStore.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/23/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "PortfoliosStore.h"
#import "UserPortfolio.h"
#import "StockItem.h"

@implementation PortfoliosStore
@synthesize indexOfCurrentPortfolio, context;


//returns an instance of the portfolio share. This will be static so it will never die and will be shared across the app.
+(PortfoliosStore *)sharedStore
{
    static PortfoliosStore *sharedStore = nil;
    if(!sharedStore) {
        sharedStore = [[super allocWithZone:nil]init];
    }
    return sharedStore;
}
//makes sure allocWithZone doesn't create a new instance of PortfoliosStore
+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedStore];
}

-(id)init
{
    self = [super init];
    if (self) {
        //read in StockDatabase.xcdatamodeld
        model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

        //where does the SQLite file go
        NSString *path = [self itemArchivePath];
        NSURL *storeURL = [NSURL fileURLWithPath:path];
        NSError *error = nil;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            [NSException raise:@"Open Failed" format:@"Reason: %@", [error localizedDescription]];
            }
        //create managed object context
        context = [[NSManagedObjectContext alloc] init];
        [context setPersistentStoreCoordinator:psc];
        
        //the managed object context can manage undo but we dont need it
        [context setUndoManager:nil];
        
        [self loadAllItems];
    }
    return self;
}

-(void)loadAllItems
{
    //LOAD PORTFOLIOS
    if (!allPortfolios) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [[model entitiesByName] objectForKey:@"UserPortfolio"];
        [request setEntity:e];

        NSError *error;
        NSArray *result = [context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise: @"Fetch failed" format: @"Reason: %@", [error localizedDescription]];
        }
        allPortfolios = [[NSMutableArray alloc] initWithArray:result];
    }
    
//LOADSTOCKS
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [[model entitiesByName] objectForKey:@"StockItem"];
    [request setEntity:e];
        
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"orderingValue" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sd]];
    
    NSError *error;
    NSArray *results = [context executeFetchRequest:request error:&error];
    if (!results) {
        [NSException raise: @"Fetch failed" format: @"Reason: %@", [error localizedDescription]];
    }
    
    
//portfolio's array of stocks is not loaded from core data. This loads the stocks into the corresponding portfolios based on the portfolioString each stock is given.
    for (StockItem *stock in results) {
        for (UserPortfolio *port in allPortfolios) {
            if (port.allStocks.count == 0) {
                port.allStocks = [[NSMutableArray alloc] init];
            }
            if ([stock.portfolioString isEqualToString:port.title]) {
                [port.allStocks addObject: stock];
            }
        }
    }
}

-(NSArray *)allPortfolios
{
    return allPortfolios;
}

-(UserPortfolio *)createPortfolio
{
    UserPortfolio *p = [NSEntityDescription insertNewObjectForEntityForName:@"UserPortfolio" inManagedObjectContext:context];
    p.title = @"somethings working";
    
//    XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXUser Portfolio is NEVER CALLS INIT - FIX THIS? XXXXXXXXXXXXXXXXXXXXXXXX
    p.allStocks = [[NSMutableArray alloc] init];
    [allPortfolios addObject:p];
    
    return p;
}

-(void)removeItem:(UserPortfolio *)p
{
    NSUInteger portfolioIndex = [allPortfolios indexOfObject:p];
    [context deleteObject:p];
    [allPortfolios removeObjectAtIndex:portfolioIndex];
    if (allPortfolios.count > 0) {
        [self setIndexOfCurrentPortfolio:0];
    }
    
}

-(void)assignCurrentPortfolio:(UserPortfolio *)p
{
    indexOfCurrentPortfolio = [self.allPortfolios indexOfObject:p];
}

//PortfoliosStore handles READING AND WRITING SAVE DATA!

-(NSString *)itemArchivePath
{
    //NSDocumentDirectory (the 1st argument) is the directory we want to sandbox to. Doing NSCachesDirectory would look in Caches directory.
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    //get one and only document directory from that list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

-(BOOL)saveChanges
{
    NSError *err = nil;
    BOOL successful = [context save:&err];
    if(!successful) {
        NSLog(@"Error saving: %@", [err localizedDescription]);
    }
    return successful;
}




@end
