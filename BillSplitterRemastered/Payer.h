//
//  Payer.h
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/13/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Item.h"
#import "PayerTotalObj.h"


@class Item;

@interface Payer : NSObject

@property(nonatomic, copy, readwrite)NSString *name; //Name of payer
@property(nonatomic, strong, readwrite)NSMutableArray *items; //Array of items that the payer has
@property(nonatomic, strong, readwrite)PayerTotalObj *payerObjectInfo; //Object to store information to display once calculated prices

-(id)initWithName:(NSString *)nameIn;
-(id)initWithName:(NSString *)nameIn andItems:(NSMutableArray *)itemsIn;
-(void)addItem:(Item *)itemIn; //adds item to item list

@end
