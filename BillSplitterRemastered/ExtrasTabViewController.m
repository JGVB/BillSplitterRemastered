//
//  ExtrasTabViewController.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "ExtrasTabViewController.h"

@interface ExtrasTabViewController ()

@property (weak, nonatomic) IBOutlet UITextField *tfFlatDiscount;
@property (weak, nonatomic) IBOutlet UITextField *tfPercentDiscount;
@property (weak, nonatomic) IBOutlet UITextField *tfExtraCharges;
@property (weak, nonatomic) IBOutlet UITextField *tfTaxAmount;
@property (weak, nonatomic) IBOutlet UITextField *tfTip;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTipByPercent;
@property (weak, nonatomic) IBOutlet UITableViewCell *cellTipByValue;
@property (weak, nonatomic) IBOutlet UILabel *lTipByQuestionMake;

@end

@implementation ExtrasTabViewController

@synthesize extrasDataSource = _extrasDataSource;
@synthesize tfExtraCharges = _tfExtraCharges;
@synthesize tfFlatDiscount = _tfFlatDiscount;
@synthesize tfPercentDiscount = _tfPercentDiscount;
@synthesize tfTaxAmount = _tfTaxAmount;
@synthesize tfTip = _tfTip;
@synthesize cellTipByPercent = _cellTipByPercent;
@synthesize cellTipByValue = _cellTipByValue;
@synthesize lTipByQuestionMake = _lTipByQuestionMake;


/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver. (required)
 **/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //Initialize
        self.extrasDataSource = [[NSMutableDictionary alloc] init];
    }
    return self;
}


/**
 * viewDidLoad: Called after the controller’s view is loaded into memory.
 **/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add gesture to tableView allowing dismissal of keyboard when background touched(and keyboard is up)
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO; //A Boolean value affecting whether touches are delivered to a view when a gesture is recognized.
    [self.tableView addGestureRecognizer:gestureRecognizer];
}


/**
 * viewWillAppear: Notifies the view controller that its view is about to be added to a view hierarchy.
 **/
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //TotalsDisplayViewController(later in queue) disables the 3 tabs in order to deter the user from navigating when viewing the totals.
    //The next few lines will re-enable the tabs when the back button is pressed from that view and tab navigation should be, once again, enabled.
    UITabBarItem *tabBarItem = [[[[self tabBarController]tabBar]items] objectAtIndex:0];
    [tabBarItem setEnabled:TRUE];
    UITabBarItem *tabBarItem1 = [[[[self tabBarController]tabBar]items] objectAtIndex:1];
    [tabBarItem1 setEnabled:TRUE];
    UITabBarItem *tabBarItem2 = [[[[self tabBarController]tabBar]items] objectAtIndex:2];
    [tabBarItem2 setEnabled:TRUE];
}


/**
 * bCalculateTotal: When user clicks "Calculate" button, this function prepares data to be sent to TotalsDisplayViewControll(initiate calculations).  Prepares the 3 data sources(payers, items, and extras).
 * If there are no items, warn user
 * If there are no payers, warn user
 * If no payers are assigned to items or visa versa, warn user
 * If all checks out, segue to TotalsDisplayViewController and calculate
 **/
- (IBAction)bCalculateTotal:(id)sender {
    //Extract data sources from ItemsTabViewController and PayersTabViewController
    ItemsTabViewController *itvc = (ItemsTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
    PayersTabViewController *ptvc = (PayersTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    //Ensure that there are items, payers, and connections between
    NSMutableArray *errors = [ErrorChecking readyToCalculate:itvc.itemDataSource andPayers:ptvc.payerDataSource andExtras:self.extrasDataSource];
    if([errors count] > 0){ //Show error messages
        [ErrorChecking showErrorMessage:errors];
    } else { //no errors, send it!
        [self performSegueWithIdentifier:@"calculate_from_extras_segue" sender:self];
    }
}


/**
 * bClearExtras: Will clear all extras when user clicks button.
 **/
- (IBAction)bClearExtras:(id)sender {
    self.extrasDataSource = [[NSMutableDictionary alloc] init];
    self.tfFlatDiscount.text = @"0";
    self.tfPercentDiscount.text = @"0";
    self.tfExtraCharges.text = @"0";
    self.tfTaxAmount.text = @"0";
    self.tfTip.text = @"0";
}


/**
 * prepareForSegue: Notifies the view controller that a segue is about to be performed. Select items for selected payer
 **/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"calculate_from_extras_segue"]){
        //Extract data sources needed
        PayersTabViewController *ptvc = (PayersTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
        ItemsTabViewController *itvc = (ItemsTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
        TotalsDisplayViewController *tdvc = (TotalsDisplayViewController *)segue.destinationViewController;
        tdvc.extrasDataSource = self.extrasDataSource;
        tdvc.payersDataSource = ptvc.payerDataSource;
        tdvc.itemsDataSource = itvc.itemDataSource;
    }
}


/**
 * dismissKeyboard: resigns first responder of the text field.
 **/
-(void)dismissKeyboard
{
    [self.tfExtraCharges resignFirstResponder];
    [self.tfFlatDiscount resignFirstResponder];
    [self.tfPercentDiscount resignFirstResponder];
    [self.tfTaxAmount resignFirstResponder];
    [self.tfTip resignFirstResponder];
}

#pragma textField Delegate

/**
 * textFieldDidEndEditing: Tells the delegate that editing stopped for the specified text field. Save when text field is done editing(avoid save button)
**/
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    //Set default value
    if([textField.text isEqualToString:@""] || textField.text == nil){
        textField.text = @"0";
    }
    
    if(![textField.text isEqualToString:@"0"]){ //Don't add extra if it's 0 (user clicks on extra and changes nothing or enters 0)
        //error check
        NSString *textFieldData = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *textFieldPlaceholder = textField.placeholder;
        NSMutableArray *errors = [ErrorChecking checkPositiveNonNegativeNonEmptyHasNonNumbers:textFieldData];
        if([errors count] == 0){ //No errors, add data
        [self.extrasDataSource setObject:[ErrorChecking formatNumberTo2DecimalPlaces:textFieldData] forKey:textFieldPlaceholder];
        } else { //Error with input entered, display error message
            //Save information when user gets off of text field.
            [ErrorChecking showErrorMessage:errors];
            textField.text = @"0";
        }
    }
}


/**
 * textFieldDidBeginEditing: Tells the delegate that editing began for the specified text field. Highlight text when text field is selected in order to make it easier to edit
**/
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    UITextPosition *start = [textField beginningOfDocument];
    UITextPosition *end   = [textField endOfDocument];
    UITextRange *range = [textField textRangeFromPosition:start toPosition:end];
    [textField setSelectedTextRange:range];
}


#pragma mark - text field delegate

/**
 * textFieldShouldReturn: Asks the delegate if the text field should process the pressing of the return button.
 **/
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

#pragma mark - Table view data source

/**
 * didSelectRowAtIndexPath: Tells the delegate that the specified row is now selected. This is used for the checkmark accessory in tipping by percent or by amount.
 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *theCellClicked = [self.tableView cellForRowAtIndexPath:indexPath]; //Get which cell was clicked
    if (theCellClicked == self.cellTipByPercent) {
        if(!self.cellTipByPercent.accessoryType == UITableViewCellAccessoryCheckmark) {
            self.lTipByQuestionMake.text = @"Tip (%)";
            [self.extrasDataSource setObject:@"tip_by_percent" forKey:@"tipByWhat"];
            self.cellTipByPercent.accessoryType = UITableViewCellAccessoryCheckmark;
            self.cellTipByValue.accessoryType = UITableViewCellAccessoryNone;
        }
    } else if (theCellClicked == self.cellTipByValue){
        if(!theCellClicked.accessoryType == UITableViewCellAccessoryCheckmark){
            self.lTipByQuestionMake.text = @"Tip ($ Amount)";
            [self.extrasDataSource setObject:@"tip_by_amount" forKey:@"tipByWhat"];
            self.cellTipByValue.accessoryType = UITableViewCellAccessoryCheckmark;
            self.cellTipByPercent.accessoryType = UITableViewCellAccessoryNone;
        }
    }
}

@end