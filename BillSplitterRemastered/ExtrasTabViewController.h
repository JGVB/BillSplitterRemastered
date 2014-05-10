//
//  ExtrasTabViewController.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ErrorChecking.h"
#import "ItemsTabViewController.h"
#import "PayersTabViewController.h"

@interface ExtrasTabViewController : UITableViewController <UITextFieldDelegate>

@property(strong, nonatomic, readwrite) NSMutableDictionary *extrasDataSource; //Data source containing all the extras data. Key is placeholder, object is user input

@end
