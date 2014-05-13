//
//  Payer.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/13/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "Payer.h"

@implementation Payer

@synthesize name = _name;
@synthesize items = _items;
@synthesize payerObjectInfo = _payerObjectInfo;

-(id)init
{
    if(self = [super init]){
        self.name = @"NO NAME";
        self.items = [[NSMutableArray alloc] init];
        self.payerObjectInfo = [[PayerTotalObj alloc] initWithName:@"NO NAME"];
    }
    return self;
}

-(id)initWithName:(NSString *)nameIn
{
    if(self = [super init]){
        self.name = nameIn;
        self.items = [[NSMutableArray alloc] init];
        self.payerObjectInfo = [[PayerTotalObj alloc] initWithName:nameIn];
    }
    return self;
}

-(id)initWithName:(NSString *)nameIn andItems:(NSMutableArray *)itemsIn
{
    if(self = [super init]){
        self.name = nameIn;
        self.items = itemsIn;
        self.payerObjectInfo = [[PayerTotalObj alloc] initWithName:nameIn];
    }
    return self;
}

-(void)addItem:(Item *)itemIn
{
    [self.items addObject:itemIn];
}


@end
