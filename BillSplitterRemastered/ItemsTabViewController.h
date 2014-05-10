//
//  ItemsTabViewController.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorChecking.h"
#import "Payer.h"
#import "Item.h"
#import "ItemSelectTableCell.h"
#import "TotalsDisplayViewController.h"
#import "SelectItemsPayersViewController.h"
#import "PayersTabViewController.h"

@interface ItemsTabViewController : UITableViewController <UITextFieldDelegate>

@property(nonatomic, strong, readwrite)NSMutableArray *itemDataSource; //Data source of all items

@end
