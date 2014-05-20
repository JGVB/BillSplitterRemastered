//
//  Item.m
//  BillSplitterRemastered
//
//  Created by James VanBeverhoudt on 2/13/14.
//  Copyright (c) 2014 noOrg. All rights reserved.
//

#import "Item.h"

@implementation Item

@synthesize name = _name;
@synthesize payers = _payers;
@synthesize cost = _cost;

-(id)init
{
    return [self initWithName:@"No Name" andCost:0 andPayers:[[NSMutableArray alloc] init]];
}

-(id)initWithName:(NSString *)nameIn andCost:(double)costIn;
{
    return [self initWithName:nameIn andCost:costIn andPayers:[[NSMutableArray alloc] init]];
}

-(id)initWithName:(NSString *)nameIn andCost:(double)costIn andPayers:(NSMutableArray *)payersIn
{
    if(self = [super init]){
        self.name = nameIn;
        self.payers = payersIn;
        self.cost = costIn;
    }
    return self;
}


-(void)addPayer:(Payer *)payerIn
{
    [self.payers addObject:payerIn];
}

@end
