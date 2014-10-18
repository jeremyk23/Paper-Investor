//
//  EntryScreenViewController.m
//  StockDatabase
//
//  Created by Jeremy Klein Sr on 7/23/13.
//  Copyright (c) 2013 Jeremy Klein. All rights reserved.
//

#import "EntryScreenViewController.h"
#import "CreatePortfolioView.h"
#import "UserPortfolio.h"
#import "StockItem.h"
#import "PortfoliosStore.h"

#import "PortfolioStocksViewController.h"
#import "Globals.h"


@interface EntryScreenViewController ()

@end

@implementation EntryScreenViewController
@synthesize customPickerArray, pickerViewContainer, activityIndicator;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    //xxxxxTEST METHODxxxxxxx//
//  [self initializeTestPortfolio];
//    xxxxxxxxxxxxxxxxxxxxxxxxx
    [super viewDidLoad];

    
    [Globals formatForiOS7:self];
    
    [pickerView reloadAllComponents];
    
    [createPortfolioButton setTitle:@"Create Portfolio" forState:UIControlStateNormal];
    
    pickerViewContainer.frame = CGRectMake(0, self.view.frame.size.height - 43, 320, 261);

    //set background image
    UIImageView *backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"greenBG_2.png"]];
    [self.view addSubview:backgroundView];
    [self.view sendSubviewToBack:backgroundView];
    
//    self.view.backgroundColor = [Globals kiwi_greenColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //The portfolio exists: fill picker view
    if ([[[PortfoliosStore sharedStore] allPortfolios] count]) {

        self.customPickerArray = [[PortfoliosStore sharedStore] allPortfolios];
        [pickerView reloadAllComponents];
        
        //get index of current portfolio
        int i = [[PortfoliosStore sharedStore] indexOfCurrentPortfolio];
        //set title of button to portfolio name
        [currentPortfolioButton setTitle:[[[[PortfoliosStore sharedStore] allPortfolios] objectAtIndex:i] title] forState:UIControlStateNormal];
        [self enableButtons];
        
        //if there are no portfolio's diable relevant labels and buttons
    } else if ([PortfoliosStore sharedStore].allPortfolios.count == 0) {
        [self disableButtons];
    }
}
-(IBAction)viewExistingPortfolio:(id)sender
{
    if ([[[PortfoliosStore sharedStore] allPortfolios] count]) {
        int i = [[PortfoliosStore sharedStore] indexOfCurrentPortfolio];
        PortfolioStocksViewController *pStocksViewController = [[PortfolioStocksViewController alloc] init];
        
        [pStocksViewController setPortfolio: [[[PortfoliosStore sharedStore] allPortfolios] objectAtIndex:i]];
        activityIndicator = [Globals startActivityIndicator:self.view];
        [pStocksViewController passParentView:(self)];
        [[self navigationController] pushViewController:pStocksViewController animated:YES];
    }
}

-(IBAction)createPortfolio:(id)sender
{
    UserPortfolio *p = [[PortfoliosStore sharedStore] createPortfolio];
    CreatePortfolioView *createPortfolioView = [[CreatePortfolioView alloc] init];
    [createPortfolioView setPortfolio:p];
    [[self navigationController] pushViewController:createPortfolioView animated:YES];
}

//PICKER STUFF

-(NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.customPickerArray.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[self.customPickerArray objectAtIndex:row] title];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    for (UserPortfolio *port in [[PortfoliosStore sharedStore] allPortfolios])
    {
        if ([[[self.customPickerArray objectAtIndex:row] title] isEqualToString:port.title]) {
            [[PortfoliosStore sharedStore] setIndexOfCurrentPortfolio:row];
            [currentPortfolioButton setTitle:port.title forState:UIControlStateNormal];
        }
    }
}
    

-(IBAction)choosePortfolio:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    pickerViewContainer.frame = CGRectMake(0, self.view.frame.size.height - 255, 320, 261);
    [UIView commitAnimations];
}

-(IBAction)hidePicker:(id)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    pickerViewContainer.frame = CGRectMake(0, self.view.frame.size.height, 320, 261);
    [UIView commitAnimations];
}

-(void)disableButtons
{
    //Disable switch to currentPortfolio
    currentPortfolioButton.enabled = NO;
    currentPortfolioButton.hidden = YES;
    
    [currentPortfolioButton setTitle:@"No Portfolio Selected" forState:UIControlStateDisabled];
    
    currentPortfolioLabel.hidden = YES;
    
    choosePortfolioButton.enabled = NO;
    choosePortfolioButton.hidden = YES;
    
    createLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 320, 280, 125)];
    createLabel.backgroundColor = [UIColor clearColor];
    createLabel.numberOfLines = 0;
    [createLabel setTextColor:[Globals kiwi_whiteColor]];
    [createLabel setText:@"Create A Portfolio To Get Started"];
    [createLabel setFont:[UIFont fontWithName:@"Futura" size:18]];
    
    [self.view addSubview:createLabel];
}

-(void) enableButtons
{
    currentPortfolioButton.enabled = YES;
    choosePortfolioButton.enabled = YES;
    currentPortfolioButton.hidden = NO;
    currentPortfolioLabel.hidden = NO;
    choosePortfolioButton.hidden = NO;
    createLabel.hidden = YES;
//    if (createLabel)
}

- (void)viewDidUnload {
    currentPortfolioButton = nil;
    [super viewDidUnload];
}


//-----------------TEST STUFF-----------------//


-(void) initializeTestPortfolio {
    /*
    UserPortfolio *testPortfolio = [[PortfoliosStore sharedStore] createPortfolio];
    testPortfolio.title = @"High Growth Portfolio";
    NSNumber *currentFunds = [[NSNumber alloc] initWithFloat: 450000];
    NSNumber *initialFunds = [[NSNumber alloc] initWithFloat: 450000];
    testPortfolio.currentFunds = currentFunds;
    testPortfolio.initialFunds = initialFunds;
    
    
    StockItem *stock1 = [testPortfolio createStock];
    [stock1 buyStockAtPriceAndDate:@"TSLA" stockItem:stock1 forPortfolio:testPortfolio sharesBought:200 pricePaid:100.05 dateCreated:@"06/26/2013"];
    
    StockItem *stock2 = [testPortfolio createStock];
    [stock2 buyStockAtPriceAndDate:@"LNKD" stockItem:stock2 forPortfolio:testPortfolio sharesBought:1000 pricePaid:155.14 dateCreated:@"02/11/2013"];
    
    StockItem *stock3 = [testPortfolio createStock];
    [stock3 buyStockAtPriceAndDate:@"ZNGA" stockItem:stock3 forPortfolio:testPortfolio sharesBought:10000 pricePaid:9.22 dateCreated:@"04/20/2012"];
    
    StockItem *stock4 = [testPortfolio createStock];
    [stock4 buyStockAtPriceAndDate:@"UA" stockItem:stock4 forPortfolio:testPortfolio sharesBought:1000 pricePaid:69.50 dateCreated:@"08/07/2012"];
    
    StockItem *stock5 = [testPortfolio createStock];
    [stock5 buyStockAtPriceAndDate:@"HD" stockItem:stock5 forPortfolio:testPortfolio sharesBought:100 pricePaid:80.03 dateCreated:@"07/12/2012"];
    
    StockItem *stock6 = [testPortfolio createStock];
    [stock6 buyStockAtPriceAndDate:@"Z" stockItem:stock6 forPortfolio:testPortfolio sharesBought:100 pricePaid:73.88 dateCreated:@"07/29/2012"];
 */
}

@end
