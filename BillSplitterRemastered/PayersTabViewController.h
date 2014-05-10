//
//  PayersTabViewController.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemsTabViewController.h"
#import "TotalsDisplayViewController.h"
#import "Item.h"
#import "Payer.h"
#import "ErrorChecking.h"
#import "SelectPayersItemsViewController.h"
#import "ExtrasTabViewController.h"

@interface PayersTabViewController : UITableViewController <UITextFieldDelegate>

@property(nonatomic, strong, readwrite) NSMutableArray *payerDataSource; //Data source for tableView. Contains Payers added by user.

@end
