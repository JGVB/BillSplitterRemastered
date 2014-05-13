//
//  PayerTotalObj.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 5/2/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PayerTotalObj : NSObject

@property(nonatomic, readwrite)double total;
@property(nonatomic, readwrite)double subtotal;
@property(nonatomic, readwrite)double percentShareOfTotal;
@property(nonatomic, copy, readwrite)NSString *name;
@property(nonatomic, strong, readwrite)NSMutableDictionary *sharedItemsAndSplitNumber; //key is an incremented number.  Object is an array with index 0) number of people item is split with, 1) the item - use to extract name and price(to divide by num of players on display)
@property(nonatomic, strong, readwrite)NSMutableDictionary *listOfExtrasApplied; //list of extras that have been applied.

-(id)initWithName:(NSString *)nameIn;
-(void)addExtraApplied:(double)extraIn withKey:(NSString *)keyNameIn;

@end
