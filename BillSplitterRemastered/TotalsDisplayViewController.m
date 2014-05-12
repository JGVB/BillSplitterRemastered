//
//  TotalsDisplayViewController.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "TotalsDisplayViewController.h"

@interface TotalsDisplayViewController ()

@property(copy, nonatomic, readwrite)NSString *grandTotal; //Stores the grand total in order to display when Grand Total cell is loaded.
@property(strong, nonatomic, readwrite)Payer *selectedPayer; //Stores the selected payer, to send to PayersDetailsDisplayViewController to show payer's details

@end

@implementation TotalsDisplayViewController

@synthesize payersDataSource = _payersDataSource;
@synthesize itemsDataSource = _itemsDataSource;
@synthesize extrasDataSource = _extrasDataSource;
@synthesize selectedPayer = _selectedPayer;
@synthesize grandTotal = _grandTotal;

/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver
 **/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //Initialize
        self.grandTotal = @"0";
        self.selectedPayer = [[Payer alloc] initWithName:@"no name"]; //Precaution
    }
    return self;
}

/**
 * viewWillAppear: Notifies the view controller that its view is about to be added to a view hierarchy. Disable tabs
 **/
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Disable tabs when calculating to prevent user from getting confused.
    for(UITabBarItem *item in [[self.tabBarController tabBar] items]){
        [item setEnabled:FALSE];
    }
}

/**
 * viewDidLoad: Called after the controller’s view is loaded into memory. Start doing the calculations
 **/
- (void)viewDidLoad
{
    [super viewDidLoad];

    //Initiate calculations
    NSMutableArray *payerTotalObjects;
    if([[self.extrasDataSource objectForKey:@"how_to_split"] isEqualToString:@"Unevenly"]){ //By default, bill is split unevenly
        payerTotalObjects = [Calculations performCalculationsWithPayersSplitUnevenly:self.payersDataSource andItems:self.itemsDataSource andExtras:self.extrasDataSource]; //Returns an array, index 0 - array of updated payer objects after calculations.  index 1 - Grand total to display in tableView
    } else { //user wants the bill split equally between all payers
       // payerTotalObjects = [Calculations]
    }
    self.payersDataSource = [payerTotalObjects objectAtIndex:0]; //gets the payers.
    double gt =[[payerTotalObjects objectAtIndex:1] doubleValue]; //Get grand total
    NSString *gtString = [ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f", gt]];
    self.grandTotal = [NSString stringWithFormat:@"$%@",gtString];
    [self.tableView reloadData]; //After payers are updated, reload tableview. Precaution
}

#pragma mark - Table view data source

/**
 * numberOfSectionsInTableView: Asks the data source to return the number of sections in the table view.
 **/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}


/**
 * titleForHeaderInSection: Asks the data source for the title of the header of the specified section of the table view.
 **/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0: //List of payers section
            sectionName = @"";
            break;
        case 1: //Grand Total Section
            sectionName = @" ";
            break;
        default: //else
            sectionName = @"";
            break;
    }
    return sectionName;
}


/**
 * numberOfRowsInSection: Tells the data source to return the number of rows in a given section of a table view. (required)
 **/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows;
    switch (section) {
        case 0: //List of payers and their totals
            numberOfRows = [self.payersDataSource count];
            break;
        case 1: //Grand total section
            numberOfRows = 1;
            break;
        default: //else
            numberOfRows = 0;
            break;
    }
    return numberOfRows;
}

/**
 * cellForRowAtIndexPath: - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
 Description
 Asks the data source for a cell to insert in a particular location of the table view. (required)
 **/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    if(indexPath.section == 0){  //Section 0 displays all payers and their totals.
        Payer *tempPayer = [self.payersDataSource objectAtIndex:indexPath.row];
        cell.textLabel.text = [tempPayer name]; //Grabs name of payer in data source
        PayerTotalObj *tempPTO = [tempPayer payerObjectInfo]; //Gets the payerTotalObject with extras information in it.
        double totalDouble =[tempPTO total];
        NSString *totalString = [ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f", totalDouble]];
        cell.detailTextLabel.text = [@"$" stringByAppendingString:totalString];
    } else if(indexPath.section == 1){ //section 1 is grand total section below all payers and their totals.
        //Make no clicking on grand total cell
        cell.accessoryType = UITableViewCellAccessoryNone; //no arrow on right side signifying not to click on this cell
        cell.userInteractionEnabled = NO;//disable cell
        cell.textLabel.text = @"Grand Total";
        cell.detailTextLabel.text = self.grandTotal;
    } else {
        //only 2 sections
    }
    return cell;
}

/**
 * prepareForSegue: Notifies the view controller that a segue is about to be performed.
**/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"payer_details_segue"]){ //segue into PayersDetailsDisplayViewController
        PayersDetailsDisplayViewController *pddvc = (PayersDetailsDisplayViewController *)segue.destinationViewController;
        pddvc.selectedPayerTotal = self.selectedPayer;//Sets the selected payer
        
    }
}

/**
 * didSelectRowAtIndexPath: Tells the delegate that the specified row is now selected.
**/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedPayer = [self.payersDataSource objectAtIndex:indexPath.row]; //Sets selected payer to send in segue
    [self performSegueWithIdentifier:@"payer_details_segue" sender:self]; //Segue into PayersDetailsDisplayViewController

}

@end
