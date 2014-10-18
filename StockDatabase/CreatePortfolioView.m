//
//  CreatePortfolioView.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/23/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "CreatePortfolioView.h"
#import "UserPortfolio.h"
#import "PortfoliosStore.h"
#import "Globals.h"

#include <math.h>


@interface CreatePortfolioView () 

@end

@implementation CreatePortfolioView
@synthesize portfolio;

-(void)setPortfolio:(UserPortfolio *)p
{
    portfolio = p;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [Globals formatForiOS7:self];
    
    [self.navigationItem setTitle:@"Create Your Portfolio"];
    initialFundLabel.hidden = YES;
    fundField.hidden = YES;
    
    //set background image
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenBG_2.png"]];
    [self.view addSubview:backgroundView];
    backgroundView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view sendSubviewToBack:backgroundView];
        
    //if this isn't the first time the user has come to this create screen, don't display the help text.
    NSArray *portfoliosArray = [[PortfoliosStore sharedStore] allPortfolios];
    if (portfoliosArray.count > 1) {
        exampleText.hidden = YES;
    }
    self.didCreate = FALSE;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.didCreate == FALSE) {
        [[PortfoliosStore sharedStore] removeItem:portfolio];
    }
    
}

- (void)viewDidUnload {
    portfolioNameField = nil;
    fundField = nil;
    [super viewDidUnload];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == portfolioNameField) {
        //if they don't enter anything, display help text. 
        if ([textField text].length == 0){
                [Globals fadeInUIView:exampleText];
                if (fundField.hidden == NO) {
                    [Globals fadeOutUIView:fundField];
                    [Globals fadeOutUIView:initialFundLabel];
                }
            }
    //        Else if they do, display the funds label.
         else if (fundField.hidden && initialFundLabel.hidden) {
            [Globals fadeInUIView:fundField];
            [Globals fadeInUIView:initialFundLabel];
        }
        //if they do enter something for the title, hide the help text
        if (![[textField text] isEqualToString:@""]) {
            [Globals fadeOutUIView:exampleText];
        }
    }
    //if the user enters something in the fund field, update the portfolio's initial funds. Done here so I know when to display "create portfolio" button.
    if ([textField isEqual:fundField]) { 
        float formattedInitialFunds = [Globals formatStringToFloat:[fundField text]];
        NSLog(@"formatted float: %f",formattedInitialFunds);
        //if it's not an invalid number, (formatStringToFloat will return 0 if its not valid.)
        if ([Globals formatStringToInt:[fundField text]]) {
            NSLog(@"you entered a valid number");
            [portfolio setInitialFunds:[NSNumber numberWithFloat: formattedInitialFunds]];
            [self displayCreateButton];
            //if they've switched their once valid number to something invalid, fade out the createPortfolioButton
        } else  {
            NSLog(@"you entered a invalid number and your at the end of the if else statement");
            [self displayInvalidNumberAlert];
            if (createPortfolioButton.hidden == NO) {
                [Globals fadeOutUIView:createPortfolioButton];
            }
        }
        [self animateTextField: textField down: YES];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [[self view] endEditing:TRUE];
    [self displayCreateButton];
}

-(void) displayCreateButton
{
    if (![[fundField text] isEqual: @""] && ![[portfolioNameField text] isEqual: @""]) {
        [Globals fadeInUIView:createPortfolioButton];
    }
}

-(void)displayInvalidNumberAlert {
    UIAlertView *numberAlert = [[UIAlertView alloc] initWithTitle:@"Invalid Number" message:@"The number you entered is invalid. Make sure your number doesn't contain letters." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [numberAlert show];
}

-(IBAction)createPortfolio:(id)sender
{
    [portfolio setTitle:[portfolioNameField text]];
    
    float formattedInitialFunds = [Globals formatStringToFloat:[fundField text]];
    [portfolio setInitialFunds:[NSNumber numberWithFloat: formattedInitialFunds]];
    [portfolio setCurrentFunds:portfolio.initialFunds];
    
    NSDate *dateCreated = [[NSDate alloc] init];
    [portfolio setDateCreated: dateCreated];
    
    //sets current portfolio by finding the index of created portfolio and assinging it to indexOfCurrentPortfolio
    [[PortfoliosStore sharedStore] setIndexOfCurrentPortfolio: [[[PortfoliosStore sharedStore] allPortfolios] indexOfObject:portfolio]];
    
    self.didCreate = TRUE;
    [[self navigationController] popViewControllerAnimated:YES];
    [[PortfoliosStore sharedStore] assignCurrentPortfolio:portfolio];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == fundField){
        [self animateTextField: textField up: YES];
    }
}

- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    [UIView animateWithDuration:0.3 animations:^{
        initialFundLabel.frame = CGRectOffset(initialFundLabel.frame, 0, -30);
        fundField.frame = CGRectOffset(fundField.frame, 0, -30);
    }];
}

- (void) animateTextField : (UITextField *)textField down: (BOOL) down
{
    [UIView animateWithDuration:0.3 animations:^{
        initialFundLabel.frame = CGRectOffset(initialFundLabel.frame, 0, 30);
        fundField.frame = CGRectOffset(fundField.frame, 0, 30);
    }];
}


@end
