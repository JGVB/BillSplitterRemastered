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
@property(nonatomic, strong, readwrite)NSMutableDictionary *sharedItemsAndSplitNumber; // of dictionaries.  Key is item name, object is number of people split with.
@property(nonatomic, strong, readwrite)NSMutableDictionary *listOfExtrasApplied; //list of extras that have been applied.

-(id)initWithName:(NSString *)nameIn;
-(void)addExtraApplied:(double)extraIn withKey:(NSString *)keyNameIn;

@end
