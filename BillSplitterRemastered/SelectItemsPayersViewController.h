//
//  SelectItemsPayersViewController.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payer.h"
#import "Item.h"
#import "FromItemSelectTableViewCell.h"

@interface SelectItemsPayersViewController : UITableViewController


@property(nonatomic, strong, readwrite) Item *selectedItem; //Item selected from ItemsTabViewController
@property(nonatomic, strong, readwrite) NSMutableArray *allPayersArray; //The payers to display to select from for each item

@end
