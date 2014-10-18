//
//  EntryScreenViewController.h
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/23/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntryScreenViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    
    __weak IBOutlet UIButton *createPortfolioButton;
    __weak IBOutlet UIButton *choosePortfolioButton;
    IBOutlet UIPickerView *pickerView;
    __weak IBOutlet UIButton *currentPortfolioButton;
//    IBOutlet UIPickerView *pickerView;
    __weak IBOutlet UILabel *currentPortfolioLabel;
    NSArray *customPickerArray;
    UILabel *createLabel;
}

-(IBAction)createPortfolio:(id)sender;
-(IBAction)viewExistingPortfolio:(id)sender;
-(IBAction)choosePortfolio:(id)sender;
- (IBAction)hidePicker:(id)sender;
- (void)disableButtons;
- (void)enableButtons;
- (void)initializeTestPortfolio;


@property (weak, nonatomic) IBOutlet UIView *pickerViewContainer;
@property (nonatomic, strong) NSArray *customPickerArray;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@end
