//
//  PayerDetailsTableViewCell.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 5/5/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayerDetailsTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lNumOfPeople; //Label holding number of people
@property (weak, nonatomic) IBOutlet UILabel *lCost; //Label holding cost of item

@end
