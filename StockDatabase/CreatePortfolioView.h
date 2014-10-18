//
//  CreatePortfolioView.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/23/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UserPortfolio;

@interface CreatePortfolioView : UIViewController <UITextFieldDelegate>
{
    __weak IBOutlet UITextField *portfolioNameField;

    __weak IBOutlet UILabel *initialFundLabel;
    __weak IBOutlet UITextField *fundField;
    __weak IBOutlet UIButton *createPortfolioButton;
    __weak IBOutlet UILabel *exampleText;

    __weak IBOutlet UILabel *namePortfolioLabel;
}

//-(BOOL)textFieldSholudReturn:(UITextField *)textField;

-(void) displayCreateButton;
-(void) displayInvalidNumberAlert;
- (IBAction)createPortfolio:(id)sender;


@property (nonatomic, strong)UserPortfolio *portfolio;
@property (nonatomic) BOOL didCreate;

@end
