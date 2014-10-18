//
//  StockItemCell.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/18/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockItemCell : UITableViewCell

- (void)willTransitionToState:(UITableViewCellStateMask)state;

@property (weak, nonatomic) IBOutlet UILabel *percentLabel;
@property (weak, nonatomic) IBOutlet UILabel *tickerLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceBoughtLabel;
@property (weak, nonatomic) IBOutlet UILabel *currentPriceLabel;

@end
