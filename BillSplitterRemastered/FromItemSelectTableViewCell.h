//
//  FromItemSelectTableViewCell.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 4/29/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FromItemSelectTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lName; //label with name of item
@property (weak, nonatomic) IBOutlet UILabel *lNumberOfPayers; //label with number of payers
@property (weak, nonatomic) IBOutlet UILabel *lPayers;

@end
