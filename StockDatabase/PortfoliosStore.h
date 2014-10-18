//
//  PortfoliosStore.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/23/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserPortfolio;

@interface PortfoliosStore : NSObject
{
    NSMutableArray *allPortfolios;
    NSManagedObjectModel *model;
}
+(PortfoliosStore *)sharedStore;
-(NSArray *)allPortfolios;
-(UserPortfolio *)createPortfolio;
-(void)removeItem:(UserPortfolio *)p;
-(void)assignCurrentPortfolio:(UserPortfolio *)p;
-(NSString *)itemArchivePath;
-(BOOL)saveChanges;
-(void)loadAllItems;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) int indexOfCurrentPortfolio;
@end

//The portal through which I talk to the database is the NSManagedObjectContext. The context uses and NSPersistentStoreCoordinator. You ask the persistent store coordinator to open an SQLite at a particular filename. The store uses the model file by an instance of the NSManagedObjectModel.

//When PortfolioStore is initialized it needs to set up a NSManagedObjectContext and A PersistentStore.
//  -PersistentStore needs to know "what are all of my entities and their attributes and relationships (instance variable values) and "where am I loading and saving from"
//    -Thus we create an NSManagedObjectModel to answer this

//use a fetch request that will get an array of all objects back that match what you specified.