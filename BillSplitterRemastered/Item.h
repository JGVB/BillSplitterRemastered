//
//  Item.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/13/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Payer.h"

@class Payer;

@interface Item : NSObject

@property(nonatomic, copy, readwrite)NSString *name; //Name of item
@property(nonatomic, readwrite)double cost; //Cost of item
@property(nonatomic, strong, readwrite)NSMutableArray *payers; //array of payers that are paying for the item

-(id)initWithName:(NSString *)nameIn andCost:(double)costIn;
-(id)initWithName:(NSString *)nameIn andCost:(double)costIn andPayers:(NSMutableArray *)payersIn;
-(void)addPayer:(Payer *)payerIn;

@end
