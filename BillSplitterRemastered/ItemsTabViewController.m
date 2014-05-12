//
//  ItemsTabViewController.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "ItemsTabViewController.h"

@interface ItemsTabViewController ()

@property(nonatomic, weak, readwrite)IBOutlet UITextField *tfItemNameInput; //Text field with the name of the item
@property(nonatomic, weak, readwrite)IBOutlet UITextField *tfItemCostInput; //Text field with the cost of the item
@property(nonatomic, strong, readwrite) Item *selectedItem; //Selected item sent to SelectItemsPayersViewController

@end

@implementation ItemsTabViewController

@synthesize itemDataSource = _itemDataSource;
@synthesize tfItemNameInput = _tfItemNameInput;
@synthesize tfItemCostInput = _tfItemCostInput;
@synthesize selectedItem = _selectedItem;

/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver. (required)
**/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //Initialize
        self.itemDataSource = [[NSMutableArray alloc] init];
        self.selectedItem = [[Item alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Add gesture to tableView allowing dismissal of keyboard when background touched(and keyboard is up)
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:gestureRecognizer];
}

/**
 * viewWillAppear: Notifies the view controller that its view is about to be added to a view hierarchy.
 **/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //TotalsDisplayViewController(later in queue) disables the 3 tabs in order to deter the user from navigating when viewing the totals.
    //The next few lines will re-enable the tabs when the back button is pressed from that view and tab navigation should be, once again, enabled.
    for(UITabBarItem *item in [[self.tabBarController tabBar] items]){
        [item setEnabled:TRUE];
    }
    
    [self.tableView reloadData]; //Reload selected cell when returned from Selecting an item's payers - refreshes the item count in detail label
}


/**
 * bCalculateTotal: When user clicks "Calculate" button, this function prepares data to be sent to TotalsDisplayViewControll(initiate calculations).  Prepares the 3 data sources(payers, items, and extras).
 * If there are no items, warn user
 * If there are no payers, warn user
 * If no payers are assigned to items or visa versa, warn user
 * If all checks out, segue to TotalsDisplayViewController and calculate
 **/
- (IBAction)bCalculateTotal:(id)sender {
    //Extract data sources from PayersTabViewController and ExtrasTabViewController
    ExtrasTabViewController *etvc = (ExtrasTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0];
    PayersTabViewController *ptvc = (PayersTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
    
    //Ensure that there are items, payers, and connections between
    NSMutableArray *errors = [ErrorChecking readyToCalculate:self.itemDataSource andPayers:ptvc.payerDataSource andExtras:etvc.extrasDataSource];
    if([errors count] > 0){ //Show error messages
        [ErrorChecking showErrorMessage:errors];
    } else { //no errors, send it!
        [self performSegueWithIdentifier:@"calculate_from_items_segue" sender:self];
    }
}

/**
 * prepareForSegue: Notifies the view controller that a segue is about to be performed.
**/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"calculate_from_items_segue"]){
        //Extract data sources from PayersTabViewController and ExtrasTabViewController
        PayersTabViewController *ptvc = (PayersTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
        ExtrasTabViewController *etvc = (ExtrasTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0];
        TotalsDisplayViewController *tdvc = (TotalsDisplayViewController *)segue.destinationViewController;
        tdvc.extrasDataSource = etvc.extrasDataSource;
        tdvc.payersDataSource = ptvc.payerDataSource; //Send payers to TotalsDisplayViewController
        tdvc.itemsDataSource = self.itemDataSource; //Send items to TotalsDisplayViewController
        
    } else if([segue.identifier isEqualToString:@"connect_items_and_payers_from_items_segue"]){
        //Extra Items data source from ItemsTabViewController
        PayersTabViewController *ptvc = (PayersTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:0] viewControllers] objectAtIndex:0];
        SelectItemsPayersViewController *sipvc = (SelectItemsPayersViewController*)segue.destinationViewController;
        sipvc.selectedItem = self.selectedItem; //Set selected item
        sipvc.allPayersArray = ptvc.payerDataSource; //Send payers
    }
}


/**
 * addItem: When user clicks add item, error check the input and if valid add to data source and update table
 **/
- (IBAction)addItem:(id)sender {
    //Get name and cost from item labels when user pressed add button
    NSString *userEnteredNameTrimmed = [self.tfItemNameInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *userEnteredCostTrimmed = [self.tfItemCostInput.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    //Check the input, if valid, add to datasource and update.
    NSMutableArray *errors = [ErrorChecking checkName:userEnteredNameTrimmed];
    [errors addObjectsFromArray:[ErrorChecking checkPositiveNonNegativeNonEmptyHasNonNumbers:userEnteredCostTrimmed]];
    if([errors count] == 0){ //No errors, add payer
        userEnteredCostTrimmed = [ErrorChecking formatNumberTo2DecimalPlaces:userEnteredCostTrimmed];
        Item *newItem = [[Item alloc] initWithName:userEnteredNameTrimmed andCost:[userEnteredCostTrimmed doubleValue]];
        [self.itemDataSource addObject:newItem];
        [self.tableView reloadData];
        [self dismissKeyboard];
        //Clear text fields
        [self.tfItemCostInput setText:@""];
        [self.tfItemNameInput setText:@""];
    } else { //Error with input entered
        [ErrorChecking showErrorMessage:errors];
    }
}

/**
 * dismissKeyboard: resigns first responder of the text field.
 **/
-(void)dismissKeyboard{
    [self.tfItemNameInput resignFirstResponder];
    [self.tfItemCostInput resignFirstResponder];
}


#pragma mark - Table view data source

/**
 * numberOfSectionsInTableView: Asks the data source to return the number of sections in the table view.
 **/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


/**
 * numberOfRowsInSection: Tells the data source to return the number of rows in a given section of a table view. (required)
 **/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.itemDataSource count];
}


/**
 * cellForRowAtIndexPath: Asks the data source for a cell to insert in a particular location of the table view. (required)
**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ItemSelectTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[ItemSelectTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Item *cellsItem = [self.itemDataSource objectAtIndex:indexPath.row];
    cell.lItemName.text = cellsItem.name;
    NSString *formatted = [ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f", cellsItem.cost]];
    cell.lItemCost.text = [@"$" stringByAppendingString:formatted];
    NSString *payersString = @" payers";
    if([cellsItem.payers count] == 1){ //Phrasing!
        payersString = @" payer";
    }
    NSString *theCount =[NSString stringWithFormat:@"%lu", (unsigned long)[cellsItem.payers count]];
    cell.lItemSharedWith.text = [theCount stringByAppendingString:payersString]; //Show how many payers the item has
    return cell;
}


/**
* canEditRowAtIndexPath: Asks the data source to verify that the given row is editable.
**/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/**
 * commitEditingStyle: Asks the data source to commit the insertion or deletion of a specified row in the receiver. Must remove payer from data source, as well as remove this payer from all item's payer array.
 **/
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Remove object from all item's payers as well as removing from self.payerDataSource
        //Loop through Item's payers and remove this item from each payer.
        NSMutableArray *itemsPayers =[(Item *)[self.itemDataSource objectAtIndex:indexPath.row] payers];
        for(Payer *payer in itemsPayers){
            NSMutableArray *payerItemsToDeletePayerFrom = [payer items];
            for(Item * item in payerItemsToDeletePayerFrom){
                if([item.name isEqualToString:[(Item *)[self.itemDataSource objectAtIndex:indexPath.row] name]]){ //Compare the payer's items to which was deleted, if it is the one, delete it!
                    [payerItemsToDeletePayerFrom removeObject:item];
                    break; //Enumeration says I can't delete an object while enumerating through the object...sooo BREAK
                }
            }
        }
        [self.itemDataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


/**
 * didSelectRowAtIndexPath: Tells the delegate that the specified row is now selected. Set selected item to the data source item at selected index to send to SelectItemsPayersViewController
**/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedItem = [self.itemDataSource objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"connect_items_and_payers_from_items_segue" sender:self];
}

#pragma mark - text field delegate

/**
 * textFieldShouldReturn: Asks the delegate if the text field should process the pressing of the return button.
**/
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
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


@end
