//
//  SelectPayersItemsViewController.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "SelectPayersItemsViewController.h"
#import "ErrorChecking.h"

@interface SelectPayersItemsViewController ()

@end

@implementation SelectPayersItemsViewController

@synthesize allItemsMutArray = _allItemsMutArray;
@synthesize selectedPayer = _selectedPayer;

/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver. (required)
**/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //initialize
        self.allItemsMutArray = [[NSMutableArray alloc] init];
        self.selectedPayer = [[Payer alloc] init];
    }
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    //Tableview background image
    UIImageView *tempImageView;
    if ([[UIScreen mainScreen] bounds].size.height == 568)
    {
        tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"billSplitterTableView_640x1136.png"]];
    }
    else
    {
        tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"billSplitterTableView_640x960.png"]];
        
    }
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero]; //Get rid of footer so lines don't appear on tableview
}

/**
 * viewWillAppear: Notifies the view controller that its view is about to be added to a view hierarchy. Refresh table view
 **/
-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
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
    return [self.allItemsMutArray count];
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
    Item *cellsItem = [self.allItemsMutArray objectAtIndex:indexPath.row];
    cell.lItemName.text = cellsItem.name;
    cell.lItemCost.text = [@"$" stringByAppendingString:[ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f",cellsItem.cost]]];
    
    NSMutableArray *sharedNames = [[NSMutableArray alloc] init];
    NSString *sharedStringNames = @"";
    for(Payer *payerItem in cellsItem.payers){ //Go through all of the item's payers and add them to array in order to know who the item is split with
        if(![payerItem.name isEqualToString:self.selectedPayer.name]){ //Do not add selected payer to this list of shared people, you don't share with yourself.
            [sharedNames addObject:payerItem.name];
        }
    }
    if([sharedNames count] > 0){ //If there are people in this shared list, we must display labels and create string for efficient displaying, and each cost
        //Show the two labels needed when split items
        cell.lItemSharedWith.hidden = NO;
        cell.lCostEach.hidden = NO;
        cell.lEach.hidden = NO;
        
        //Add names of splitters into final string
        for(NSString *name in sharedNames){ //Loop through shared names and add to string
            sharedStringNames = [[sharedStringNames stringByAppendingString:name] stringByAppendingString:@", "];
        }
        
        //Remove last comma
        sharedStringNames = [sharedStringNames substringToIndex:sharedStringNames.length - 2];
        
        //Add label's "each" cost
        double costSplit = cellsItem.cost / [cellsItem.payers count]; //Get cost of item / number of payers to get split cost
        NSString *formattedCost = [ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f", costSplit]]; //Format split cost
        cell.lCostEach.text = [@"$" stringByAppendingString:formattedCost];
    } else {
        cell.lItemSharedWith.hidden = YES;
    }
    cell.lItemSharedWith.text = [@"Split With: " stringByAppendingString:sharedStringNames];
    
    //Set checkmark accessory
    if([self.selectedPayer.items containsObject:cellsItem]){ //If the cell is in the selected payer's item list - put checkmark on it!
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;

    }
    return cell;
}


/**
 * didSelectRowAtIndexPath: Tells the delegate that the specified row is now selected. This function updates the data source when you click on an item.  It will add 
 * remove the items from the payer's item list, remove the payer from the item's payer list.  As well as add the item to the payer's item list and add the payer to the item's payer list.
**/
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ItemSelectTableCell *cell = (ItemSelectTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if(cell.accessoryType == UITableViewCellAccessoryCheckmark){ //take out of array
        cell.accessoryType = UITableViewCellAccessoryNone;
        //remove item from payer's item list
        NSMutableArray *modItems = self.selectedPayer.items;
        [modItems removeObject:[self.allItemsMutArray objectAtIndex:indexPath.row]];
        self.selectedPayer.items = modItems;
        //remove payer from item's payer list
        Item *selectedItem = [self.allItemsMutArray objectAtIndex:indexPath.row];
        NSMutableArray *payerList = selectedItem.payers;
        [payerList removeObject:self.selectedPayer];
        selectedItem.payers = payerList;
    } else { //add to array
        //Add the item to the payer's item list
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        NSMutableArray *itemss = self.selectedPayer.items;
        [itemss addObject:[self.allItemsMutArray objectAtIndex:indexPath.row]];
        self.selectedPayer.items = itemss;
        //add the payer to the item's payer list
        Item *selectedItem = [self.allItemsMutArray objectAtIndex:indexPath.row];
        [selectedItem addPayer:self.selectedPayer];
    }
    [self.tableView reloadData];
}


@end
