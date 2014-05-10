//
//  PayersDetailsDisplayViewController.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payer.h"
#import "PayerTotalObj.h"
#import "PayerDetailsTableViewCell.h"
#import "ErrorChecking.h"

@interface PayersDetailsDisplayViewController : UITableViewController

@property(strong, nonatomic, readwrite)Payer *selectedPayerTotal; //Selected payer with updated calculations in it

@end
