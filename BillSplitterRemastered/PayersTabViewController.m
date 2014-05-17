//
//  PayersTabViewController.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "PayersTabViewController.h"

@interface PayersTabViewController ()

@property(nonatomic, weak, readwrite)IBOutlet UITextField *tfPayerNameInput; //Text Field to hold the name of the payer entered.
@property(nonatomic, strong, readwrite) Payer *selectedPayer; //Once the user selects a Payer, store in this property to send to next VC.

@end

@implementation PayersTabViewController

@synthesize payerDataSource = _payerDataSource;
@synthesize tfPayerNameInput = _tfPayerNameInput;
@synthesize selectedPayer = _selectedPayer;

/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver
 **/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //Initialized
        self.payerDataSource = [[NSMutableArray alloc] init];
        self.selectedPayer = [[Payer alloc] init];
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
    
    //Tableview background image
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"billSplitter640x1136.png"]];
    [tempImageView setFrame:self.tableView.frame];
    
    self.tableView.backgroundView = tempImageView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //Get rid of footer so lines don't appear on tableview

}

/**
 * viewWillAppear: Notifies the view controller that its view is about to be added to a view hierarchy.
 **/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //TotalsDisplayViewController(later in queue) disables the 3 tabs in order to deter the user from navigating when viewing the totals.
    //The next few lines will re-enable the tabs when the back button is pressed from that view and tab navigation should be, once again, enabled.
    //Disable tabs when calculating to prevent user from getting confused.
    for(UITabBarItem *item in [[self.tabBarController tabBar] items]){
        [item setEnabled:TRUE];
    }
    
    [self.tableView reloadData]; //Reload selected cell when returned from Selecting a payer's items - refreshes the item count in detail label
}

/**
 * bCalculateTotal: When user clicks "Calculate" button, this function prepares data to be sent to TotalsDisplayViewControll(initiate calculations).  Prepares the 3 data sources(payers, items, and extras).
 * If there are no items, warn user
 * If there are no payers, warn user
 * If no payers are assigned to items or visa versa, warn user
 * If all checks out, segue to TotalsDisplayViewController and calculate
 **/
- (IBAction)bCalculateTotal:(id)sender {
    //Extract data sources from ItemsTabViewController and ExtrasTabViewController
    ItemsTabViewController *itvc = (ItemsTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
    ExtrasTabViewController *etvc = (ExtrasTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0];
    
    //Ensure that there are items, payers, and connections between
    NSMutableArray *errors = [ErrorChecking readyToCalculate:itvc.itemDataSource andPayers:self.payerDataSource andExtras:etvc.extrasDataSource];
    if([errors count] > 0){ //Show error messages
        [ErrorChecking showErrorMessage:errors];
    } else { //no errors, send it!
        [self performSegueWithIdentifier:@"calculate_from_payers_segue" sender:self];
    }
}

/**
 * prepareForSegue: Notifies the view controller that a segue is about to be performed. Two segues.  1)Calculate 2) Select items for selected payer
 **/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"calculate_from_payers_segue"]){ //User clicks on calculate button
        //Extract data sources from ItemsTabViewController and ExtrasTabViewController
        ItemsTabViewController *itvc = (ItemsTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
        ExtrasTabViewController *etvc = (ExtrasTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:2] viewControllers] objectAtIndex:0];
        TotalsDisplayViewController *tdvc = (TotalsDisplayViewController *)segue.destinationViewController;
        tdvc.extrasDataSource = etvc.extrasDataSource;
        tdvc.payersDataSource = self.payerDataSource; //Send payers to TotalsDisplayViewController
        tdvc.itemsDataSource = itvc.itemDataSource; //Send items to TotalsDisplayViewController
    } else if ([segue.identifier isEqualToString:@"connect_items_and_payers_from_payers_segue"]){ //Segue to select items for selected payer
        //Extra Items data source from ItemsTabViewController
        ItemsTabViewController *itvc = (ItemsTabViewController *)[[(UINavigationController *)[[self.tabBarController viewControllers] objectAtIndex:1] viewControllers] objectAtIndex:0];
        SelectPayersItemsViewController *spivc = (SelectPayersItemsViewController *)segue.destinationViewController;
        spivc.selectedPayer = self.selectedPayer; //Send selected payer to display that payer's items
        spivc.allItemsMutArray = itvc.itemDataSource; //Send items from ItemsTabViewController to be selected from
    }
}


/**
 * addPayer: Called when user hits the add button. Will add a payer to the data source. Also error checks the name
 **/
- (IBAction)addPayer:(id)sender {
    NSString *userEnteredName = self.tfPayerNameInput.text; //Extracts name from textField
    userEnteredName= [userEnteredName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]; //Gets rid of white spaces

    NSMutableArray *errors = [ErrorChecking checkName:userEnteredName andReusedNames:self.payerDataSource]; //Check user name for correct format
    if([errors count] == 0){ //No errors, add payer
        Payer *newPayer = [[Payer alloc] initWithName:userEnteredName];
        [self.payerDataSource addObject:newPayer];
        [self.tableView reloadData];
        [self dismissKeyboard];
    } else { //Error with input entered - show error messages
        [ErrorChecking showErrorMessage:errors];
    }
    [self.tfPayerNameInput setText:@""]; //Clear payer name from text field once button is pressed
}


/**
 * dismissKeyboard: resigns first responder of the text field.
 **/
-(void)dismissKeyboard
{
    [self.tfPayerNameInput resignFirstResponder];
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
    return [self.payerDataSource count];
}


/**
 * cellForRowAtIndexPath: Asks the data source for a cell to insert in a particular location of the table view. (required)
 **/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    Payer *cellsPayer = [self.payerDataSource objectAtIndex:indexPath.row]; //Grab the current payer
    cell.textLabel.text = cellsPayer.name; //Set text field to the Payer's name
    NSString *count = [NSString stringWithFormat:@"%lu", (unsigned long)[cellsPayer.items count]]; //Get number of items that payer has to display on detail.
    NSString *itemss = @" Items"; //For 0 and 2 - lazy 8  items
    if([cellsPayer.items count] == 1){//Grammar!
        itemss = @" Item";
    }
    cell.detailTextLabel.text = [count stringByAppendingString:itemss];
    return cell;
}

/**
 * didSelectRowAtIndexPath: Tells the delegate that the specified row is now selected. Sets the selected payer to send when segue is triggered.  Initiate segue.
 **/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPayer = [self.payerDataSource objectAtIndex:indexPath.row]; //Set the selected data source payer
    [self performSegueWithIdentifier:@"connect_items_and_payers_from_payers_segue" sender:self]; //Initiate segue to select Items for selected payer.
}


#pragma mark - text field delegate

/**
 * textFieldShouldReturn: Asks the delegate if the text field should process the pressing of the return button.
 **/
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

/**
 * canEditRowAtIndexPath: Asks the data source to verify that the given row is editable.
 **/
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Override to support conditional editing of the table view.
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/**
 * commitEditingStyle: Asks the data source to commit the insertion or deletion of a specified row in the receiver. Must remove payer from data source, as well as remove this payer from all item's payer array.
 **/
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Override to support editing the table view.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //Remove object from all item's payers as well as removing from self.payerDataSource
        //Loop through payer's items and remove this payer from each item.
        NSMutableArray *payersItems =[(Payer *)[self.payerDataSource objectAtIndex:indexPath.row] items];
        for(Item *item in payersItems){
            NSMutableArray *itemPayersToDeletePayerFrom = [item payers];
            for(Payer * payer in itemPayersToDeletePayerFrom){
                if([payer.name isEqualToString:[(Payer *)[self.payerDataSource objectAtIndex:indexPath.row] name]]){ //Compare the item's payers to which was deleted, if it is the one, delete it!
                    [itemPayersToDeletePayerFrom removeObject:payer];
                    break; //Enumeration says I can't delete an object while enumerating through the object...sooo BREAK
                }
            }
        }
        [self.payerDataSource removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        //no insert
    }   
}


@end
