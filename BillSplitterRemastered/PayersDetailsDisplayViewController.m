//
//  PayersDetailsDisplayViewController.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "PayersDetailsDisplayViewController.h"

@interface PayersDetailsDisplayViewController ()

@property(nonatomic, strong, readwrite)NSMutableArray *displayingExtraKeysArray;//Holds the keys to the extra data in the order to be displayed

@end

@implementation PayersDetailsDisplayViewController

@synthesize selectedPayerTotal = _selectedPayerTotal;


/**
 * initWithCoder: Returns an object initialized from data in a given unarchiver
 **/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]){
        //Initialize
        self.selectedPayerTotal = [[Payer alloc] initWithName:@"no name"];
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

#pragma mark - Table view data source

/**
 * numberOfSectionsInTableView: Asks the data source to return the number of sections in the table view.
 **/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 4;
}

/**
 * numberOfRowsInSection: Tells the data source to return the number of rows in a given section of a table view. (required)
 **/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows;
    switch (section) {
        case 0: //Section 0 is bill for payer section
            numberOfRows = 0;
            break;
        case 1: //Section 1 is items and their shares section
            numberOfRows = [self.selectedPayerTotal.payerObjectInfo.sharedItemsAndSplitNumber count];
            break;
        case 2: //Section 2 is the subtotal and extras
            numberOfRows = [self.selectedPayerTotal.payerObjectInfo.listOfExtrasApplied count];
            break;
        default: //Section 3 is the payer's total and percent share of total
            numberOfRows = 1;
    }
    return numberOfRows;
}


/**
 * titleForHeaderInSection: Asks the data source for the title of the header of the specified section of the table view.
**/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0: //bill for payer section
            sectionName = [NSString stringWithFormat:@"Bill for %@", self.selectedPayerTotal.name];
            break;
        case 1: //Items and their shares section
            sectionName = ([self.selectedPayerTotal.payerObjectInfo.sharedItemsAndSplitNumber count] == 1) ? @"1 Item" : [NSString stringWithFormat:@"%lu Items", (unsigned long)[self.selectedPayerTotal.payerObjectInfo.sharedItemsAndSplitNumber count]];
            break;
        case 2: //Subtotal and extras section
            sectionName = [NSString stringWithFormat:@"Subtotal: $%@", [ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f",self.selectedPayerTotal.payerObjectInfo.subtotal]]];
            break;
        case 3: //Total section
            sectionName = [NSString stringWithFormat:@"Total: $%@", [ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f", self.selectedPayerTotal.payerObjectInfo.total]]];
            break;
        default: //else
            sectionName = @"";
            break;
    }
    return sectionName;
}


/**
 * cellForRowAtIndexPath: Asks the data source for a cell to insert in a particular location of the table view. (required)
**/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    PayerDetailsTableViewCell *cell = (PayerDetailsTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[PayerDetailsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //extra charges
    //Flat discount
    //percent discount
    //tax
    //tip
    
    // Configure the cell...
    //Items
    if(indexPath.section == 1){ //Section 1 contains all the payer's items and how many people the selected payer splits it with.
        NSArray *listOfSplitKeysItemName = [self.selectedPayerTotal.payerObjectInfo.sharedItemsAndSplitNumber allKeys];
        NSInteger numOfPeopleSplitWith = [[[self.selectedPayerTotal.payerObjectInfo.sharedItemsAndSplitNumber objectForKey:[listOfSplitKeysItemName objectAtIndex:indexPath.row]] objectAtIndex:0] integerValue]; //Gets number of payers for an object
        NSString *stringNum = [NSString stringWithFormat:@"%li", (long)numOfPeopleSplitWith];
        NSString *itemName = [[[self.selectedPayerTotal.payerObjectInfo.sharedItemsAndSplitNumber objectForKey:[listOfSplitKeysItemName objectAtIndex:indexPath.row]] objectAtIndex:1] name]; //get the name of the item
        NSString *appended = @"";
        if([stringNum isEqualToString:@"1"]){ //If there is one item, grammar will be 1 of ITEM X
            appended =[[@"1" stringByAppendingString:@" of "]
                       stringByAppendingString:itemName];
        } else { //If there are two or more items, grammar will be 1/2 of ITEM X
            appended = [[[@"1/" stringByAppendingString:stringNum]
                                   stringByAppendingString:@" of "]
                                  stringByAppendingString:itemName];
        }
        cell.lNumOfPeople.text = appended;
        
        //Item Cost
        double costDouble = [[[self.selectedPayerTotal.payerObjectInfo.sharedItemsAndSplitNumber objectForKey:[listOfSplitKeysItemName objectAtIndex:indexPath.row]] objectAtIndex:1] cost];//Get cost of item data source
        costDouble = costDouble / numOfPeopleSplitWith; //Divide the item price by number of people splitting it.
        NSString *cost = [NSString stringWithFormat:@"%f", costDouble];
        cost = [ErrorChecking formatNumberTo2DecimalPlaces:cost];
        cell.lCost.text = [@"$" stringByAppendingString:cost];
    
    } else if(indexPath.section == 2){ //Subtotal in header and extras in tableview rows
        NSString *titleLabel = [self.selectedPayerTotal.payerObjectInfo.listOfExtrasApplied nameAtIndex:indexPath.row];//gets key of extra applied
        NSNumber *detailLabel = [self.selectedPayerTotal.payerObjectInfo.listOfExtrasApplied objectAtIndex:indexPath.row];//gets object of extra applied
        NSString *stringDetailLabelCost = [ErrorChecking formatNumberTo2DecimalPlaces:[detailLabel stringValue]];
        titleLabel = [titleLabel stringByAppendingString:@":"];
        cell.lNumOfPeople.text = titleLabel;
        cell.lCost.text = [[self.selectedPayerTotal.payerObjectInfo.listOfExtrasApplied signAtIndex:indexPath.row] stringByAppendingString:[@"$" stringByAppendingString:stringDetailLabelCost]];
    } else if(indexPath.section == 3){ //Section 3 has the total-> as well as the percent share of total of the payer
        cell.lNumOfPeople.text = @"Percent share of total:";
        NSString *stringPercent =  [ErrorChecking formatNumberTo2DecimalPlaces:[NSString stringWithFormat:@"%f", (self.selectedPayerTotal.payerObjectInfo.percentShareOfTotal*100)]];
        cell.lCost.text =[stringPercent stringByAppendingString:@"%"];
    }
    return cell;
}


@end
