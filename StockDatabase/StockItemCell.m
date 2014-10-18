//
//  StockItemCell.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/18/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "StockItemCell.h"

@implementation StockItemCell
@synthesize percentLabel;

-(void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    
    if (state == UITableViewCellStateDefaultMask) {
        
        NSLog(@"Default");
        // When the cell returns to normal (not editing)
        // Do something...
        
        [UIView animateWithDuration:0.3
         
                         animations:^ {
                             self.percentLabel.alpha = 1.0f;
                         }
         ];
        
    } else if ((state & UITableViewCellStateShowingEditControlMask) && (state & UITableViewCellStateShowingDeleteConfirmationMask)) {
        
        NSLog(@"Edit Control + Delete Button");
        // When the cell goes from Showing-the-Edit-Control (-) to Showing-the-Edit-Control (-) AND the Delete Button [Delete]
        // !!! It's important to have this BEFORE just showing the Edit Control because the edit control applies to both cases.!!!
        // Do something...
        
        
        
    } else if (state & UITableViewCellStateShowingEditControlMask) {
        
        NSLog(@"Edit Control Only");
        // When the cell goes into edit mode and Shows-the-Edit-Control (-)
        // Do something...
        [UIView animateWithDuration:0.3
         
                         animations:^ {
                             self.percentLabel.alpha = 0.0f;
                         }
         ];
       
        
    } else if (state == UITableViewCellStateShowingDeleteConfirmationMask) {
        
        NSLog(@"Swipe to Delete [Delete] button only");
        // When the user swipes a row to delete without using the edit button.
        // Do something...
        [UIView animateWithDuration:0.3
         
                         animations:^ {
                             self.percentLabel.alpha = 0.0f;
                         }
         ];
    }
}

@end
