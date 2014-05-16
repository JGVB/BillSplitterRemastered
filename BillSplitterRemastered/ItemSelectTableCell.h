//
//  ItemSelectTableCell.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/12/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemSelectTableCell : UITableViewCell

@property(nonatomic, weak, readwrite)IBOutlet UILabel *lItemName; //label with item name
@property(nonatomic, weak, readwrite)IBOutlet UILabel *lItemCost; //label with item cost
@property(nonatomic, weak, readwrite)IBOutlet UILabel *lItemSharedWith; //Label having people shared with
@property (weak, nonatomic) IBOutlet UILabel *lCostEach; //Label with cost for each
@property (weak, nonatomic) IBOutlet UILabel *lEach; //Word each

@end
