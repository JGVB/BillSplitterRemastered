//
//  TotalsDisplayViewController.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Calculations.h"
#import "Item.h"
#import "Payer.h"
#import "PayerTotalObj.h"
#import "ErrorChecking.h"
#import "PayersDetailsDisplayViewController.h"

@interface TotalsDisplayViewController : UITableViewController

@property(nonatomic, strong, readwrite)NSMutableArray *payersDataSource; //Stores all payers
@property(nonatomic, strong, readwrite)NSMutableArray *itemsDataSource; //Stores all items
@property(nonatomic, strong, readwrite)NSMutableDictionary *extrasDataSource; //Stores all extras

@end
