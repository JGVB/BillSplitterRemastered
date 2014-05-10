//
//  SelectItemsPayersViewController.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "SelectItemsPayersViewController.h"

@interface SelectItemsPayersViewController ()

@end

@implementation SelectItemsPayersViewController

@synthesize allPayersArray = _allPayersArray;
@synthesize selectedItem = _selectedItem;

/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver. (required)
 **/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //initialize
        self.allPayersArray = [[NSMutableArray alloc] init];
        self.selectedItem = [[Item alloc] init];
    }
    return self;
}


/**
 * viewDidLoad: Called after the controller’s view is loaded into memory.
**/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = [NSString stringWithFormat:@"Select %@'s Payers", self.selectedItem.name]; //Set the title to a more personalized title with the item selected
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
    return [self.allPayersArray count];
}


/**
 * cellForRowAtIndexPath: Asks the data source for a cell to insert in a particular location of the table view. (required)
 **/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
     FromItemSelectTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[FromItemSelectTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    Payer *cellsPayer = [self.allPayersArray objectAtIndex:indexPath.row]; //Get the payer from the data source at the selected indexpath
    cell.lName.text = cellsPayer.name;
    NSInteger amountOfPayers = [cellsPayer.items count];
    cell.lNumberOfPayers.text = [NSString stringWithFormat:@"%ld", (long)amountOfPayers];
    if(amountOfPayers == 1){//Change label to speak proper english
        cell.lPayers.text = @"Item";
    } else {
        cell.lPayers.text = @"Items";
    }
    
    //Set Checkmark accessory
    if([self.selectedItem.payers containsObject:cellsPayer]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}


/**
 * didSelectRowAtIndexPath: Tells the delegate that the specified row is now selected. Will remove payer from item's payer list and remove item from payer's item list.  Will also add payer to item's payer list and add item to payer's item list.
**/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){ //take out of array
        cell.accessoryType = UITableViewCellAccessoryNone;
        //remove payer from item's payer list
        NSMutableArray *modPayers = self.selectedItem.payers;
        [modPayers removeObject:[self.allPayersArray objectAtIndex:indexPath.row]];
        self.selectedItem.payers = modPayers;
        //remove item from payer's item list
        Payer *selectedPayer = [self.allPayersArray objectAtIndex:indexPath.row];
        NSMutableArray *itemList = selectedPayer.items;
        [itemList removeObject:self.selectedItem];
        selectedPayer.items = itemList;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        //Add payer to item's payer list
        NSMutableArray *payerss = self.selectedItem.payers;
        [payerss addObject:[self.allPayersArray objectAtIndex:indexPath.row]];
        self.selectedItem.payers = payerss;
        //Add item to payer's item list
        Payer *selectedPayer = [self.allPayersArray objectAtIndex:indexPath.row];
        [selectedPayer addItem:self.selectedItem];
    }
    [self.tableView reloadData]; //update number of items each payer has when you add this one
}


@end
