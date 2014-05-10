//
//  SelectPayersItemsViewController.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Payer.h"
#import "Item.h"
#import "ItemSelectTableCell.h"


@interface SelectPayersItemsViewController : UITableViewController

@property(nonatomic, strong, readwrite) Payer *selectedPayer; //Selected payer selected from PayersTabViewController
@property(nonatomic, strong, readwrite) NSMutableArray *allItemsMutArray; //All items set from PayersTabViewController

@end
